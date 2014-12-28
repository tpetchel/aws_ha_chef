#
# Cookbook Name:: aws_ha_chef
# Recipe:: primary
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

include_recipe "aws_ha_chef::hosts"
include_recipe "aws_ha_chef::disable_iptables"
include_recipe "aws_ha_chef::floating_ip"
include_recipe "aws_ha_chef::server"
include_recipe "aws_ha_chef::ha"
include_recipe "aws_ha_chef::configfile"
include_recipe "aws_ha_chef::ebs_volume"

# Create missing keepalived cluster status files
directory '/var/opt/opscode/keepalived' do
  action :create
  owner 'root'
  group 'root'
  mode '0755'
end

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

# Must be run before attempting to install reporting
execute "chef-server-ctl reconfigure"
execute "chef-server-ctl start"

# Make sure we have installed the push jobs and reporting add-ons
#include_recipe 'aws_ha_chef::reporting'
#include_recipe 'aws_ha_chef::push_jobs'

# Configure for reporting and push jobs
execute 'opscode-reporting-ctl reconfigure'
execute 'opscode-push-jobs-server-ctl reconfigure'

# Yo dawg, I heard you like to configure Chef Server
# We put a reconfigure command in your configuration recipe
# So you can configure while you configure
execute "chef-server-ctl reconfigure"

# Start up Chef server on the primary
# At this point we don't want to restart or reconfigure it again
# Fsck the secondary server, it's jelly of my EBS volume
execute "chef-server-ctl restart"

# At this point we should have a working primary backend.  Let's pack up all
# the configs and make them available to the other machines.
execute "tar -czvf #{Chef::Config[:file_cache_path]}/core_bundle.tar.gz /etc/opscode" do
  action :run
  not_if { File.exist?("#{Chef::Config[:file_cache_path]}/core_bundle.tar.gz") }
end

execute "tar -czvf #{Chef::Config[:file_cache_path]}/reporting_bundle.tar.gz /etc/opscode-reporting" do
  action :run
  not_if { File.exist?("#{Chef::Config[:file_cache_path]}/reporting_bundle.tar.gz") }
end

# Install netcat
package 'nc'
package 'at'
service 'atd' do
  action :start
end

# Now we have to have a way to serve it to the other machines.  
# We'l spin up a lightweight Ruby webserver for this purpose.
template '/etc/init.d/ruby_webserver' do
  action :create
  owner 'root'
  group 'root'
  mode '0755'
  source 'ruby_webserver.erb'
end

# Sadly this does not work. Chef thinks it is up_to_date every time. ;-(
#service 'ruby_webserver' do
#  action :start
#  supports :status => true
#end

# Hacky workaround, but it gets the files served up
execute 'start_webserver' do
  command "echo '/etc/init.d/ruby_webserver start' | at now + 1 minute"
  not_if 'nc -z localhost 31337'
end
