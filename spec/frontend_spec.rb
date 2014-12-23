# encoding: UTF-8
require 'spec_helper'

# This tests the configfile recipe
describe 'tiered-chef-server::frontend' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  # ChefSpec doesn't run real commands, so we stub them here
  #before do
  #  stub_command('private-chef-ctl reconfigure').and_return(true)
  #end

  it 'creates root\'s .ssh directory' do
    expect(chef_run).to create_directory('/root/.ssh')
  end

  it 'creates root\'s authorized_keys file' do
    expect(chef_run).to render_file('/root/.ssh/authorized_keys')
  end

end
