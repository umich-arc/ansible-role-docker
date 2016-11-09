# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'spec_helper'

def py_pkgs
  return property['_docker_py_pkg']['debian'] if %w(debian ubuntu).include?(os[:family])
  return property['_docker_py_pkg']['redhat'] if %w(redhat).include?(os[:family])
end

if property['docker_manage_py']
  RSpec.describe ENV['KITCHEN_INSTANCE'] || host_inventory['hostname'] do
    context 'DOCKER:PY' do
      case property['docker_py_install']
      when 'pkg'
        context 'DOCKER:PY:PKG' do
          describe 'system docker-py package' do
            subject { package(py_pkgs) }
            it { is_expected.to be_installed }
          end
        end
      when 'pip'
        context 'DOCKER:PY:PIP' do
          describe 'pip should be installed' do
            subject { command('which pip') }
            its(:exit_status) { is_expected.to eq 0 }
          end

          if property['docker_py_pip_upgrade']
            describe 'pip should not be listed as outdated' do
              subject { command('pip list --outdated') }
              its(:stdout) { is_expected.not_to match(/^pip/) }
            end
          end

          if property['docker_py_version']
            describe 'The docker-py package version' do
              subject { command('pip list | grep docker-py') }
              its(:stdout) { is_expected.to match property['docker_py_version'] }
            end
          end
        end
      end

      context 'DOCKER:PY:MODULE' do
        verify_command =
          'python -c "import sys, pkgutil;  ' \
          'sys.exit(0) if pkgutil.find_loader(\'docker\') else sys.exit(1)"'
        describe 'docker-py library should be loadable' do
          subject { command(verify_command) }
          its(:exit_status) { is_expected.to eq 0 }
        end
      end
    end
  end
end
