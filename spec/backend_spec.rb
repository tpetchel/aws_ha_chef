# encoding: UTF-8
require 'spec_helper'

# This tests the configfile recipe
describe 'tiered-chef-server::backend' do
  let(:ipaddress) { '192.168.155.10' }
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  # ChefSpec doesn't run real commands, so we stub them here
  before do
    stub_command('private-chef-ctl reconfigure').and_return(true)
  end

  it 'configures the private Chef server' do
    expect(chef_run).to run_execute('private-chef-ctl reconfigure')
  end

  it 'creates root\'s .ssh directory' do
    expect(chef_run).to create_directory('/root/.ssh')
  end

  it 'creates root\'s private ssh key' do
    expect(chef_run).to render_file('/root/.ssh/id_rsa')
  end

  it 'removes root\'s private ssh key' do
    expect(chef_run).to delete_file('/root/.ssh/id_rsa')
  end

  it 'copies the config files and certs to the frontends' do
    expect(chef_run).to run_execute("scp -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -r /etc/opscode root@#{ipaddress}:/etc")
  end

  it 'connects to the frontend servers and configures them' do
    expect(chef_run).to run_execute("ssh -t -t -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@#{ipaddress} 'private-chef-ctl reconfigure'")
  end

end
