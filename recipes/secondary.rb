#
# Cookbook Name:: aws_ha_chef
# Recipe:: secondary
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'aws_ha_chef::hosts'
include_recipe 'aws_ha_chef::disable_iptables'
include_recipe 'aws_ha_chef::server'
include_recipe 'aws_ha_chef::ha'
include_recipe 'aws_ha_chef::push_jobs'
include_recipe 'aws_ha_chef::reporting'

# Make sure we have LVM installed in case of failover
package "lvm2" do
  action :install
end

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

# Do the cluster configuration
include_recipe "aws_ha_chef::cluster"
