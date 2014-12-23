#
# Cookbook Name:: tiered-chef-server
# Recipe:: backend
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

# Configures the back-end server in a tiered configuration with an arbitrary
# number of frontend hosts.

# Fall back on the demo setup if the frontends are not set
unless node['chef-server']['frontends'].size > 0
  node.default['chef-server']['frontends'] = {
    'frontend1.chef-demo.com' => '192.168.155.10',
    'frontend2.chef-demo.com' => '192.168.155.11'
  }
  Chef::Log.debug 'No frontend servers specified, using the default demo settings.'
end

# This command generates the certificates and configs that must be distributed
# to all the frontend hosts. Make sure /etc/opscode is empty on your frontend
# hosts before syncing files over.
execute 'private-chef-ctl reconfigure' do
  not_if { File.exist?('/etc/opscode/webui_pub.pem') }
end

# Create root's .ssh directory
directory '/root/.ssh' do
  action :create
  owner 'root'
  group 'root'
  mode '0700'
end

# Create a temporary SSH key for pushing files to the front-end machines
cookbook_file '/root/.ssh/id_rsa' do
  source 'id_rsa'
  owner 'root'
  group 'root'
  mode '0600'
end

# Configure and set up the backend server
execute 'opscode-reporting-ctl reconfigure'

execute 'opscode-push-jobs-server-ctl reconfigure'

execute 'private-chef-ctl restart opscode-pushy-server'

# Configure and setup each of the frontend servers
# We are making a direct ssh connection to each of the frontend machines
# because all of the config files and certs are on the backend host.
# In the future this might be replaced with chef-metal.
# All of the guards below only check the backend server for config
# directories. The assumption is that you are going to configure your
# frontend servers the same way.

node['chef-server']['frontends'].each do |_fqdn, ipaddress|
  # Sync the Chef server files to the front-end machine
  execute "scp -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -r /etc/opscode root@#{ipaddress}:/etc"
  # Sync the push_jobs config
  execute "scp -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -r /etc/opscode-push-jobs-server root@#{ipaddress}:/etc"
  # Sync the reporting config
  execute "scp -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -r /etc/opscode-reporting root@#{ipaddress}:/etc"
  # Run private-chef-ctl reconfigure
  execute "ssh -t -t -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@#{ipaddress} 'private-chef-ctl reconfigure'"
  # Reconfigure for reporting
  execute "ssh -t -t -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@#{ipaddress} 'opscode-reporting-ctl reconfigure'"
  # Reconfigure for push-jobs
  execute "ssh -t -t -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@#{ipaddress} 'opscode-push-jobs-server-ctl reconfigure'"
  # Reconfigure for manageui
  execute "ssh -t -t -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@#{ipaddress} 'opscode-manage-ctl reconfigure'"
  # Restart opscode-manage-ctl
  execute "ssh -t -t -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@#{ipaddress} 'opscode-manage-ctl restart'"

  # IMPORTANT NOTE:
  # It appears chef-server-ctl reconfigure always generates these configs,
  # regardless of whether or not the server type is backend or frontend.
  # Therefore, the frontend recipe /etc/opscode clean when it is finished
  # running. Always build your front-end servers first and the backend one
  # last.

end

# Remove the temporary SSH private key
file '/root/.ssh/id_rsa' do
  action :delete
  backup false
end

# Reconfigure one more time for good measure
execute 'final_reconfigure' do
  command 'private-chef-ctl reconfigure'
end
