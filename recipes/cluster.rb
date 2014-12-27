#
# Cookbook Name:: aws_ha_chef
# Recipe:: cluster
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

# Run this recipe on every server *but* the primary to configure everything

# Sync the Chef server files from the primary backend
remote_file "#{Chef::Config[:file_cache_path]}/core_bundle.tar.gz" do
  action :create
  source "http://#{node['aws_ha_chef']['backend1']['fqdn']}:31337/core_bundle.tar.gz"
  owner "root"
  group "root"
  mode "0644"
  retries 10
  retry_delay 60
end

# Sync the reporting files from the primary backend
remote_file "#{Chef::Config[:file_cache_path]}/reporting_bundle.tar.gz" do
  action :create
  source "http://#{node['aws_ha_chef']['backend1']['fqdn']}:31337/reporting_bundle.tar.gz"
  owner "root"
  group "root"
  mode "0644"
  retries 10
  retry_delay 60
end

# Unpack the server files
execute "cd /; tar -zxvf #{Chef::Config[:file_cache_path]}/core_bundle.tar.gz" do
  action :run
  cwd "/"
end

# Unpack the reporting files
execute "cd /; tar -zxvf #{Chef::Config[:file_cache_path]}/reporting_bundle.tar.gz" do
  action :run
  cwd "/"
end

# Configure all the things
execute 'chef-server-ctl reconfigure'
execute 'opscode-reporting-ctl reconfigure'
execute 'opscode-push-jobs-server-ctl reconfigure'
execute 'opscode-manage-ctl reconfigure' do
  action :run
  only_if "rpm -q opscode-manage"
end
