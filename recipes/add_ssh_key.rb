#
# Cookbook Name:: aws_ha_chef
# Recipe:: add_ssh_key
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

# This recipe sets up a temporary ssh key so that the backend server can push
# its configs into /etc/opscode.  These configs are generated on the backend
# server and are unique to each host.

directory '/root/.ssh' do
  action :create
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file '/root/.ssh/aws_chef_ha.pub' do
  action :create
  owner 'root'
  group 'root'
  mode '0600'
  source 'id_rsa.pub'
end

# This is the temporary key we use to schlep files between hosts.
# Run the remove_ssh_key recipe to get rid of it
execute 'add_ssh_key' do
  command 'cat /root/.ssh/aws_chef_ha.pub >> /root/.ssh/authorized_keys'
  not_if "grep -q aws_ha_chef_key /root/.ssh/authorized_keys"
end
