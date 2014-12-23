#
# Cookbook Name:: aws_ha_chef
# Recipe:: ha
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#
# This recipe only installs the Chef core server software, but does not configure it
# It can be used on both front-end and back-end servers

# Use the 'server_file' helper to strip filename off the end of URLs.
# This way you don't have to store URLs and filenames separately.
chef_ha_filepath = "#{Chef::Config[:file_cache_path]}/#{server_file(node['aws_ha_chef']['urls']['ha'])}"

remote_file chef_ha_filepath do
  source node['aws_ha_chef']['urls']['ha']
end

package 'chef-ha' do
  action :install
  source chef_ha_filepath
end
