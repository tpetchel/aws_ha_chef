#
# Cookbook Name:: aws_ha_chef
# Recipe:: reporting
#
# This recipe installs the reporting UI add-on.

# Configuration is handled via the primary.rb recipe
# which configures the primary back-end server and 
# distributes necessary config files to other nodes.

execute 'chef-server-ctl install opscode-reporting' do
  not_if "rpm -q opscode-reporting"
end
