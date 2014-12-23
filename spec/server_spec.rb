# encoding: UTF-8
require 'spec_helper'

# This tests the configfile recipe
describe 'tiered-chef-server::server' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  # ChefSpec doesn't run real commands, so we stub them here
  #before do
  #  stub_command('getent group appids').and_return(false)
  #end

  it 'downloads the enterprise Chef installer' do
    expect(chef_run).to create_remote_file('/var/chef/cache/private-chef_11.1.4-1_amd64.deb')
  end

  it 'installs the Chef server from a deb file' do
    expect(chef_run).to install_dpkg_package('private-chef')
  end

end
