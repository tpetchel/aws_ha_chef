#
# Cookbook Name:: aws_ha_chef
# Recipe:: hostsfile
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#
# This recipe configures /etc/hosts so you can do local testing with 'fake'
# hostnames that are not in DNS.

unless node['aws_ha_chef']['frontends'].size > 0
  node.default['aws_ha_chef']['frontends'] = {
    'frontend1.chef-demo.com' => '192.168.155.10',
    'frontend2.chef-demo.com' => '192.168.155.11'
  }
  Chef::Log.debug 'No frontend servers specified, using the default demo settings.'
end

# Fix the /etc/hosts file with the addresses of the front and back-end machines
execute "echo '#{node['aws_ha_chef']['backend']['ipaddress']} #{node['aws_ha_chef']['backend']['fqdn']}' >> /etc/hosts" do
  not_if "grep -q #{node['aws_ha_chef']['backend']['fqdn']} /etc/hosts"
end

# Add the front-end servers to the hosts file as well
node['aws_ha_chef']['frontends'].each do |fqdn, ipaddress|
  execute "echo '#{ipaddress} #{fqdn}' >> /etc/hosts" do
    not_if "grep -q #{fqdn} /etc/hosts"
  end
end
