#
# Cookbook Name:: aws_ha_chef
# Recipe:: frontend
#

include_recipe 'aws_ha_chef::hosts'
include_recipe 'aws_ha_chef::disable_iptables'
include_recipe 'aws_ha_chef::server'
include_recipe 'aws_ha_chef::push_jobs'
include_recipe 'aws_ha_chef::reporting'
include_recipe 'aws_ha_chef::manage'
include_recipe 'aws_ha_chef::cluster'
