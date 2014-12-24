#
# Cookbook Name:: aws_ha_chef
# Recipe:: manage
#
# This recipe installs the manage UI add-on.

execute 'chef-server-ctl install opscode-manage' do
  not_if "rpm -q opscode-manage"
end
