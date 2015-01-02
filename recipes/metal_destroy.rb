#
# Cookbook Name:: aws_ha_chef
# Recipe:: metal_create
#

# Creates an HA Chef 12 cluster in AWS.  
# This recipe requires customized versions of chef-provisioning and 
# chef-provisioning-aws to work properly. Specifically the issues are:
#
# 1. We have to be able to specify the version of the chef client on the 
#    target machines in order for the LVM cookbook to work.
# 2. We had to hard-code the username that chef-provisioning-aws uses to 
#    'root' instead of 'ubuntu'. For some reason specifying :ssh_username 
#    was not working.

require 'chef/provisioning/aws_driver'

# The developers have abandoned the fog driver, but not yet updated all the 
# documentation. Don't fall in the tar pit like I did!
#with_driver 'fog:AWS'
with_driver 'aws'

# Provision primary backend
# Why can't we read node attributes from the cookbook
#machine node['aws_ha_chef']['backend1']['fqdn'] do

machine_batch do
  machine 'backend1.example.local' do
    recipe 'aws_ha_chef::primary'
    machine_options({
      :bootstrap_options => {
        # Why can't we just read these in from the default attributes?
        :availability_zone => 'us-west-2a',
        :subnet_id => 'subnet-4d70cd28',
        :security_group_ids => ['sg-7dabec18', 'sg-59b6f13c'],
        :private_ip_address => '172.25.10.98',
        :key_name => ENV['AWS_SSH_KEY_ID'],
        :instance_type => 'm3.medium'
      },
      :image_id => 'ami-b6bdde86'
    })
    attributes(
      aws_ha_chef: {
        # You'll need to create an IAM user and store its creds in your 
        # environment variables.  Don't use your personal keys here!
        aws_access_key_id: ENV['CHEF_HA_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['CHEF_HA_SECRET_ACCESS_KEY']
      }
    )
    action :destroy
  end
  
  # Provision secondary backend
  #machine node['aws_ha_chef']['backend2']['fqdn'] do
  machine 'backend2.example.local' do
    recipe 'aws_ha_chef::secondary'
    machine_options({
      :bootstrap_options => {
        # Why can't we just read these in from the default attributes?
        :availability_zone => 'us-west-2a',
        :subnet_id => 'subnet-4d70cd28',
        :security_group_ids => ['sg-7dabec18', 'sg-59b6f13c'],
        :private_ip_address => '172.25.10.99',
        :key_name => ENV['AWS_SSH_KEY_ID'],
        :instance_type => 'm3.medium'
     },
     :image_id => 'ami-b6bdde86'
    })
    attributes(
      aws_ha_chef: {
        # You'll need to create an IAM user and store its creds in your 
        # environment variables.  Don't use your personal keys here!
        aws_access_key_id: ENV['CHEF_HA_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['CHEF_HA_SECRET_ACCESS_KEY']
      }
    )
    action :destroy
  end
  
  # Provision frontends
  frontends = {
    'fe1' => { 'fqdn' => 'frontend1.example.local', 'ip_address' => '172.25.10.100' },
    'fe2' => { 'fqdn' => 'frontend2.example.local', 'ip_address' => '172.25.10.101' },
    'fe3' => { 'fqdn' => 'frontend3.example.local', 'ip_address' => '172.25.10.102' }
  }
  #node['aws_ha_chef']['frontends'].each do |_host, host_data|
  frontends.each do |_host, host_data|
    machine host_data['fqdn'] do
      recipe 'aws_ha_chef::frontend'
      machine_options({
        :bootstrap_options => {
          # Why can't we just read this in from the default attributes?
          :availability_zone => 'us-west-2a',
          :subnet_id => 'subnet-4d70cd28',
          :security_group_ids => ['sg-7dabec18', 'sg-e9b7f08c'],
          :private_ip_address => host_data['ip_address'],
          :key_name => ENV['AWS_SSH_KEY_ID'],
          :instance_type => 'm1.small'
        },
        :image_id => 'ami-b6bdde86'
      })
      attributes(
        aws_ha_chef: {
          # You'll need to create an IAM user and store its creds in your 
          # environment variables.  Don't use your personal keys here!
          aws_access_key_id: ENV['CHEF_HA_ACCESS_KEY_ID'],
          aws_secret_access_key: ENV['CHEF_HA_SECRET_ACCESS_KEY']
        }
      )
      action :destroy
    end
  end
end
