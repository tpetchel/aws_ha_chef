# encoding: UTF-8
require 'spec_helper'

# This tests the configfile recipe
describe 'aws_ha_chef::frontend' do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge(described_recipe) }

  # ChefSpec doesn't run real commands, so we stub them here
  #before do
  #  stub_command('private-chef-ctl reconfigure').and_return(true)
  #end
end
