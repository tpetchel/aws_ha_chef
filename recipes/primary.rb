#
# Cookbook Name:: aws_ha_chef
# Recipe:: primary
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

# Run this recipe on your primary back-end server, *before* you run the 
# cluster recipe.  This recipe sets up all the config files for the cluster.

ruby_block 'log_ebs_volume_id' do
  block do
    Chef::Log.info("The EBS volume ID is: #{node.run_state['ebs_volume_id']}")
  end
end

# Make sure we have installed the push jobs and reporting add-ons
include_recipe 'aws_ha_chef::push_jobs'
include_recipe 'aws_ha_chef::reporting'

ruby_block 'get_ebs_volume_id' do
  block do
    if node['aws_ha_chef']['ebs_volume_id'] == ''
      # Use the ebs_volume recipe to auto-create the EBS volume
      $ebs_vol_id = node.run_state['ebs_volume_id']
      $ebs_vol_id = node['aws']['ebs_volume']['chef_ebs_volume']['volume_id']
    else
      # Or if you prefer, configure it and attach it manually
      # Just set the node attribute below to your vol-XXXXXXX id
      $ebs_vol_id = node['aws_ha_chef']['ebs_volume_id']
    end
  end
end

# Render the chef-server.rb config file
template '/etc/opscode/chef-server.rb' do
  action :create
  source 'chef-server.erb'
  owner 'root'
  group 'root'
  variables(
    lazy {
      {:ebs_volume_id => $ebs_vol_id}
    }
  )
  mode '0644'
end

# Create missing keepalived cluster status files
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
