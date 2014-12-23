#
# Cookbook Name:: tiered-chef-server
# Recipe:: reporting
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#
# This recipe only installs the reporting add on.  The backend recipe will enable
# it for both your front and back-end servers.

# Use the 'server_file' helper to strip filename off the end of URLs.
# This way you don't have to store URLs and filenames separately.
filepath = "#{Chef::Config[:file_cache_path]}/#{server_file(node['chef-server']['urls']['reporting'])}"

remote_file filepath do
  source node['chef-server']['urls']['reporting']
end

dpkg_package 'reporting' do
  action :install
  source filepath
end

directory '/etc/opscode-reporting' do
  action :create
  owner 'root'
  group 'root'
  mode '0755'
end
