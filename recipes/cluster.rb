#
# Cookbook Name:: aws_ha_chef
# Recipe:: cluster
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

# Run this recipe *last* on your primary back-end server.  It will sync all
# config files across the cluster, configure and restart all services.

# Generate all the config files for the entire cluster
execute 'chef-server-ctl reconfigure'
execute 'opscode-reporting-ctl reconfigure'

# Create root's .ssh directory
directory '/root/.ssh' do
  action :create
  owner 'root'
  group 'root'
  mode '0700'
end

# Create a temporary SSH key for pushing files to the front-end machines
cookbook_file '/root/.ssh/aws_ha_chef' do
  source 'id_rsa'
  owner 'root'
  group 'root'
  mode '0600'
end

##############################################################################
# Configure and setup the front-end servers
##############################################################################

node['aws_ha_chef']['frontends'].each do |_host, host_data|

  frontend_ip = host_data['ip_address']

  # Sync the Chef server files to the front-end machine
  execute "scp -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no -r /etc/opscode root@#{frontend_ip}:/etc"

  # Sync the reporting files
  execute "scp -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no -r /etc/opscode-reporting root@#{frontend_ip}:/etc"

  # Run chef-server-ctl reconfigure
  execute "ssh -t -t -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no root@#{frontend_ip} 'chef-server-ctl reconfigure'"

  # Reconfigure for reporting
  execute "ssh -t -t -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no root@#{frontend_ip} 'opscode-reporting-ctl reconfigure'"

  # Reconfigure for push-jobs
  execute "ssh -t -t -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no root@#{frontend_ip} 'opscode-push-jobs-server-ctl reconfigure'"

  # Reconfigure for manageui
  execute "ssh -t -t -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no root@#{frontend_ip} 'opscode-manage-ctl reconfigure'"

  # Lock the door on our way out
  execute "ssh -t -t -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no root@#{frontend_ip} 'sed -i \'/aws_ha_chef_key/d\' /root/.ssh/authorized_keys'"
end

##############################################################################
# Configure and setup the secondary back-end server
##############################################################################

# IP address of the secondary backend machine
backend_ip = node['aws_ha_chef']['backend2']['ip_address']

# Sync configs to the secondary backend machine
execute "scp -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no -r /etc/opscode root@#{backend_ip}:/etc"

# Sync the reporting files
execute "scp -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no -r /etc/opscode-reporting root@#{backend_ip}:/etc"

# Run chef-server-ctl reconfigure
execute "ssh -t -t -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no root@#{backend_ip} 'chef-server-ctl reconfigure'"

# Reconfigure for reporting
execute "ssh -t -t -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no root@#{backend_ip} 'opscode-reporting-ctl reconfigure'"

# Reconfigure for push-jobs
execute "ssh -t -t -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no root@#{backend_ip} 'opscode-push-jobs-server-ctl reconfigure'"

# Lock the door on our way out
execute "ssh -t -t -i /root/.ssh/aws_ha_chef -o StrictHostKeyChecking=no root@#{backend_ip} 'sed -i \'/aws_ha_chef_key/d\' /root/.ssh/authorized_keys'"

# Remove the temporary SSH private key
file '/root/.ssh/aws_ha_chef' do
  action :delete
  backup false
end
