# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'spec_helper'

if property['docker_manage_images'] && property['docker_images']
  RSpec.describe ENV['KITCHEN_INSTANCE'] || host_inventory['hostname'] do
    context 'DOCKER:IMAGES' do
      property['docker_images'].each do |image|
        image_name = image['name'] + ':' + (image['tag'] || 'latest')
        describe docker_image(image_name) do
          if (image['state'] || 'present').casecmp('present' || 'build')
            it { should exist }
          else
            it { should_not exist }
          end
        end
      end
    end
  end
end
