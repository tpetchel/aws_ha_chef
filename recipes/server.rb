#
# Cookbook Name:: aws_ha_chef
# Recipe:: server
#
# This recipe only installs the Chef core server software, but does not configure it.
# It can be used on both front-end and back-end servers.

# Use the 'server_file' helper to strip filename off the end of URLs.
# This way you don't have to store URLs and filenames separately.
chef_core_filepath = "#{Chef::Config[:file_cache_path]}/#{server_file(node['aws_ha_chef']['urls']['core'])}"

remote_file chef_core_filepath do
  source node['aws_ha_chef']['urls']['core']
end

package 'chef-server-core' do
  action :install
  source chef_core_filepath
end
