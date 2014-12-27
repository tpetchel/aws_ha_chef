#
# Cookbook Name:: aws_ha_chef
# Recipe:: primary
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

# Run this recipe on your secondary back-end server, *before* you run the 
# cluster recipe.  This recipe sets up all the config files for the cluster.

# Create missing keepalived cluster status files
directory '/var/opt/opscode/keepalived' do
  action :create
  owner 'root'
  group 'root'
  mode '0755'
end

file '/var/opt/opscode/keepalived/current_cluster_status' do
  action :create
  content 'backup'
  owner 'root'
  group 'root'
  mode '0644'
end

file '/var/opt/opscode/keepalived/requested_cluster_status' do
  action :create
  content 'backup'
  owner 'root'
  group 'root'
  mode '0644'
end

# Prevent this machine from trying to usurp the true master
execute 'chef-server-ctl stop keepalived'
