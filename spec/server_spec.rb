# encoding: UTF-8
require 'spec_helper'

# This tests the configfile recipe
describe 'aws_ha_chef::server' do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge(described_recipe) }

  # ChefSpec doesn't run real commands, so we stub them here
  #before do
  #  stub_command('getent group appids').and_return(false)
  #end

end
