#
# Cookbook Name:: aws_ha_chef
# Recipe:: frontend
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

cookbook_file '/root/.ssh/authorized_keys' do
  action :create
  owner 'root'
  group 'root'
  mode '0600'
  source 'id_rsa.pub'
end
