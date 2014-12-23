#
# Cookbook Name:: tiered-chef-server
# Recipe:: push_jobs
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#
# This recipe only installs the Chef server software, but does not configure it
# It can be used on both front-end and back-end servers

# Use the 'server_file' helper to strip filename off the end of URLs.
# This way you don't have to store URLs and filenames separately.
filepath = "#{Chef::Config[:file_cache_path]}/#{server_file(node['chef-server']['urls']['push_jobs'])}"

remote_file filepath do
  source node['chef-server']['urls']['push_jobs']
end

dpkg_package 'push_jobs' do
  action :install
  source filepath
end
