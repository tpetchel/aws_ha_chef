#
# Cookbook Name:: tiered-chef-server
# Recipe:: hostsfile
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#
# This recipe configures /etc/hosts so you can do local testing with 'fake'
# hostnames that are not in DNS.

unless node['chef-server']['frontends'].size > 0
  node.default['chef-server']['frontends'] = {
    'frontend1.chef-demo.com' => '192.168.155.10',
    'frontend2.chef-demo.com' => '192.168.155.11'
  }
  Chef::Log.debug 'No frontend servers specified, using the default demo settings.'
end

# Fix the /etc/hosts file with the addresses of the front and back-end machines
execute "echo '#{node['chef-server']['backend']['ipaddress']} #{node['chef-server']['backend']['fqdn']}' >> /etc/hosts" do
  not_if "grep -q #{node['chef-server']['backend']['fqdn']} /etc/hosts"
end

# Add the front-end servers to the hosts file as well
node['chef-server']['frontends'].each do |fqdn, ipaddress|
  execute "echo '#{ipaddress} #{fqdn}' >> /etc/hosts" do
    not_if "grep -q #{fqdn} /etc/hosts"
  end
end
