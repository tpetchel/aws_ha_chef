# encoding: UTF-8
require 'spec_helper'

# This tests the configfile recipe
describe 'aws_ha_chef::secondary' do
  let(:ipaddress) { '192.168.155.10' }
  let(:chef_run) { ChefSpec::ServerRunner.new.converge(described_recipe) }
end
