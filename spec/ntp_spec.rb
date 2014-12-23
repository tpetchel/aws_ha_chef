# encoding: UTF-8
require 'spec_helper'

# This tests the configfile recipe
describe 'tiered-chef-server::ntp' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  # ChefSpec doesn't run real commands, so we stub them here
  #before do
  #  stub_command('getent group appids').and_return(false)
  #end

  it 'installs the NTP package' do
    expect(chef_run).to install_package('ntp')
  end

end
