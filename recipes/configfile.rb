#
# Cookbook Name:: tiered-chef-server
# Recipe:: configfile
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

# This recipe simply sets up the private Chef server config file from a template.

directory '/etc/opscode' do
  action :create
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/opscode/private-chef.rb' do
  action :create
  owner 'root'
  group 'root'
  mode '0644'
  source 'private-chef.erb'
end
