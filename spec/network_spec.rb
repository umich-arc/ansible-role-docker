# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'spec_helper'

if property['docker_manage_engine_networks'] && property['docker_networks']
  RSpec.describe ENV['KITCHEN_INSTANCE'] || host_inventory['hostname'] do
    context 'DOCKER:NETWORKS' do
      property['docker_networks'].each do |network|
        describe "Docker network #{network['name']}" do
          subject { command("docker network inspect #{network['name']}") }
          its(:stdout) { is_expected.to_not match(/Error: No such network: #{network['name']}/) }
        end
      end
    end
  end
end
