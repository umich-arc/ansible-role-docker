# -*- encoding: utf-8 -*-
# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength

require 'spec_helper'

def engine_repo_conf
  return '/etc/yum.repos.d/Docker.repo' if %w(redhat).include?(os[:family])
  return '/etc/apt/sources.list.d/docker.list' if %w(debian ubuntu).include?(os[:family])
end

def which_process?
  if property['docker_engine_version']
    return 'dockerd' if
      Gem::Version.new(property['docker_engine_version']) >= Gem::Version.new('1.12.0')
    return 'docker'
  end
  'dockerd'
end

RSpec.describe ENV['KITCHEN_INSTANCE'] || host_inventory['hostname'] do
  describe 'DOCKER:ENGINE' do
    if property['docker_manage_engine_repo']
      context 'DOCKER:ENGINE:REPO' do
        describe 'The docker engine repo config' do
          subject { file(engine_repo_conf) }
          it { is_expected.to exist }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
          it { is_expected.to be_mode 644 }
        end
      end
    end

    context 'DOCKER:ENGINE:INSTALL' do
      describe 'The docker engine package' do
        subject { package("docker-#{property['docker_engine_edition']}") }
        it { is_expected.to be_installed }

        if property['docker_engine_version']
          context 'version' do
            subject { command('docker --version') }
            its(:stdout) { is_expected.to match property['docker_engine_version'] }
          end
        end
      end

      describe 'The docker engine service' do
        subject { service('docker') }
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end

      describe 'The docker engine process' do
        subject { process(which_process?) }
        it { is_expected.to be_running }
        if property['docker_engine_opts']
          context 'should have the arguments' do
            property['docker_engine_opts'].each do |k, v|
              v.each { |sub_v| its(:args) { is_expected.to match "--#{k}=#{sub_v}" } }
            end
          end
        end
        if property['docker_engine_env_vars']
          describe 'should be started with environment variables' do
            subject { command('cat /proc/$(pgrep --oldest docker)/environ') }
            property['docker_engine_env_vars'].each do |k, v|
              its(:stdout) { is_expected.to match(/#{k}=#{v}/i) }
            end
          end
        end
      end
    end

    if property['docker_manage_engine_users'] && property['docker_engine_users']
      context 'DOCKER:ENGINE:USERS' do
        context 'Users are grouped correctly' do
          property['docker_engine_users'].each do |user|
            describe user(user) do
              it { is_expected.to belong_to_group 'docker' }
            end
          end
        end
      end

    end
  end
end

# rubocop:enable Metrics/BlockLength
