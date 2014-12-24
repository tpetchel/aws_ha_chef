#
# Cookbook Name:: aws_ha_chef
# Recipe:: remove_ssh_key
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

# This recipe removes the temporary ssh key

# Delete the temporary key file
file '/root/.ssh/aws_chef_ha.pub' do
  action :delete
  backup false
end

# Delete the private key too, if it exists
file '/root/.ssh/aws_chef_ha' do
  action :delete
  backup false
end

# Remove the key from root's authorized_keys
execute 'remove_ssh_key' do
  command "sed -i '/aws_ha_chef_key/d' /root/.ssh/authorized_keys"
  only_if "grep -q aws_ha_chef_key /root/.ssh/authorized_keys"
end
