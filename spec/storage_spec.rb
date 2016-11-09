# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'deep_merge'
require 'spec_helper'

def btrfs_pgks
  return 'btrfs-progs' if %w(redhat).include?(os[:family])
  return 'btrfs-tools' if %w(debian ubuntu).include?(os[:family])
end

if property['docker_manage_engine_storage'] == true && property['docker_engine_storage_driver']
  RSpec.describe ENV['KITCHEN_INSTANCE'] || host_inventory['hostname'] do
    des_config = {}
    des_config.update(property['_docker_engine_storage_defaults'][
                      property['docker_engine_storage_driver']])
    des_config.deep_merge(property['docker_engine_storage_config'])

    context 'DOCKER:STORAGE' do
      case property['docker_engine_storage_driver']

      when 'aufs'
        context 'DOCKER:STORAGE:AUFS' do
          describe 'The aufs package' do
            subject { package('aufs-tools') }
            it { is_expected.to be_installed }
          end
          describe 'The docker daemon' do
            subject { process('dockerd') }
            its(:args) { is_expected.to match '--storage-driver=aufs' }
            its(:args) { is_expected.to match "--graph=#{des_config['graph']}" }
          end
        end

      when 'btrfs'
        context 'DOCKER:STORAGE:BTRFS' do
          describe 'The btrfs package' do
            subject { package(btrfs_pgks) }
            it { is_expected.to be_installed }
          end
          describe 'The docker graph directory' do
            subject { file(des_config['graph']) }
            it { is_expected.to be_mounted.with(device: des_config['device'], type: 'btrfs') }
          end
          describe 'The docker daemon' do
            subject { process('dockerd') }
            its(:args) { is_expected.to match '--storage-driver=btrfs' }
            its(:args) { is_expected.to match "--graph=#{des_config['graph']}" }
          end
        end

      when 'devicemapper'
        context 'DOCKER:STORAGE:DEVICEMAPPER' do
          describe 'The lvm2 package' do
            subject { package('lvm2') }
            it { is_expected.to be_installed }
          end
          describe 'The docker thinpool should be monitored' do
            subject { command("lvs #{des_config['vg_name']} -o+seg_monitor") }
            its(:stdout) { is_expected.to match(/#{des_config['lv_name']}.*monitored$/) }
          end

          before do
            @storage_opt =
              'dm.thinpooldev=/dev/mapper/' \
              "#{des_config['vg_name'].gsub(/-/, '--')}-" \
              "#{des_config['lv_name'].gsub(/-/, '--')}"
          end
          describe 'The docker daemon' do
            subject { process('dockerd') }
            its(:args) { is_expected.to match '--storage-driver=devicemapper' }
            its(:args) { is_expected.to match "--storage-opt=#{@storage_opt}" }
          end
        end

      when 'overlay'
        context 'DOCKER:STORAGE:OVERLAY' do
          describe 'The docker daemon' do
            subject { process('dockerd') }
            its(:args) { is_expected.to match '--storage-driver=overlay' }
            its(:args) { is_expected.to match "--graph=#{des_config['graph']}" }
          end
        end

      end
    end
  end
end
