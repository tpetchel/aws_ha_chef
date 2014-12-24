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

log "The EBS volume ID is: #{node.run_state['ebs_volume_id']}"

# Make sure we have installed the push jobs and reporting add-ons
include_recipe 'aws_ha_chef::push_jobs'
include_recipe 'aws_ha_chef::reporting'

if node['aws_ha_chef']['ebs_volume_id'] == ''
  # Use the ebs_volume recipe to auto-create the EBS volume
  ebs_vol_id = node.run_state['ebs_volume_id']
else
  # Or if you prefer, configure it and attach it manually
  # Just set the node attribute below to your vol-XXXXXXX id
  ebs_vol_id = node['aws_ha_chef']['ebs_volume_id']
end

# Render the chef-server.rb config file
template '/etc/opscode/chef-server.rb' do
  action :create
  source 'chef-server.erb'
  owner 'root'
  group 'root'
  variables(
    :ebs_volume_id => ebs_vol_id
  )
  mode '0644'
end
