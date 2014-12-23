#
# Cookbook Name:: aws_ha_chef
# Recipe:: manage
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#
# This recipe installs the 'manage' addon which provides a nicer GUI
# for the Enterprise Chef server. There are no shared files between
# front and backend servers.

# Use the 'server_file' helper to strip filename off the end of URLs.
# This way you don't have to store URLs and filenames separately.
filepath = "#{Chef::Config[:file_cache_path]}/#{server_file(node['aws_ha_chef']['urls']['manage'])}"

remote_file filepath do
  source node['aws_ha_chef']['urls']['manage']
end

dpkg_package 'manage' do
  action :install
  source filepath
end

# Pick up new configs, just in case.
execute 'private-chef-ctl reconfigure'

# Reconfigure the webui manage console
execute 'opscode-manage-ctl reconfigure' do
  only_if "grep -A2 #{node['fqdn']} /etc/opscode/aws_ha_chef-running.json | grep role | grep frontend"
end
