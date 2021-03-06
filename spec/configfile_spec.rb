# encoding: UTF-8
require 'spec_helper'

# This tests the configfile recipe
describe 'aws_ha_chef::configfile' do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge(described_recipe) }

  # ChefSpec doesn't run real commands, so we stub them here
  #before do
  #  stub_command('getent group appids').and_return(false)
  #end

  it 'creates the Chef config file directory' do
    expect(chef_run).to create_directory('/etc/opscode')
  end

  it 'renders the Chef server config file' do
    expect(chef_run).to render_file('/etc/opscode/chef-server.rb')
  end
end
