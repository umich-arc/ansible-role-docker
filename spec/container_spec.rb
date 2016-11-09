# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'spec_helper'

if property['docker_manage_containers'] && property['docker_containers']
  RSpec.describe ENV['KITCHEN_INSTANCE'] || host_inventory['hostname'] do
    context 'DOCKER:CONTAINERS' do
      property['docker_containers'].each do |container|
        describe docker_container(container['name']) do
          container_state = (container['state'] || 'started')
          case container_state
          when 'absent'
            it { should_not exist }
            it { should_not be_running }
          when 'started'
            it { should exist }
            it { should be_running }
          when 'stopped'
            it { should exist }
            it { should_not be_running }
          when 'present'
            it { should exist }
          end
        end
      end
    end
  end
end
