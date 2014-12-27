#
# Cookbook Name:: aws_ha_chef
# Recipe:: primary
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

include_recipe "aws_ha_chef::configfile"

# Run this recipe on your primary back-end server, *before* you run the 
# cluster recipe.  This recipe sets up all the config files for the cluster.

# Create missing keepalived cluster status files
directory '/var/opt/opscode/keepalived' do
  action :create
  owner 'root'
  group 'root'
  mode '0755'
end

# This breaks the reconfigure command
file '/var/opt/opscode/keepalived/current_cluster_status' do
  action :create
  content 'master'
  owner 'root'
  group 'root'
  mode '0644'
end

file '/var/opt/opscode/keepalived/requested_cluster_status' do
  action :create
  content 'master'
  owner 'root'
  group 'root'
  mode '0644'
end

# We have to run chef-server-ctl recongfigure at least once so that the reporting
# installation will work. 

execute "chef-server-ctl reconfigure"
