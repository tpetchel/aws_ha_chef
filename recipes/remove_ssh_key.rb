#
# Cookbook Name:: aws_ha_chef
# Recipe:: remove_ssh_key
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

# This recipe removes the temporary ssh key

directory '/root/.ssh' do
  action :create
  owner 'root'
  group 'root'
  mode '0755'
end

# Delete the temporary key file
cookbook_file '/root/.ssh/aws_chef_ha.pub' do
  action :delete
end

# Remove the key from root's authorized_keys
execute 'remove_ssh_key' do
  command "sed -i '/aws_ha_chef_key/d' /root/.ssh/authorized_keys"
  only_if "grep -q aws_ha_chef_key /root/.ssh/authorized_keys"
end
