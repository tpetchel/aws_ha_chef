#
# Cookbook Name:: aws_ha_chef
# Recipe:: floating_ip
#

# Configures a secondary IP address on the primary back end server

# Not sure if these are really needed
#package 'gcc' do
#  action :install
#end.run_action(:install)
#
#package 'ruby-devel' do
#  action :install
#end.run_action(:install)

chef_gem 'nokogiri' do
  version '1.6.1'
  action :install
end

chef_gem 'fog'
require 'fog'

# Fetch our MAC address
mac = File.read('/sys/class/net/eth0/address').strip
# Use the MAC to get our AWS interface ID
eth0_interface_id = `curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/#{mac}/interface-id`

log "print_network_info" do
  message "My MAC address is #{mac}\nMy interface id is #{eth0_interface_id}"
  level :debug
end

# Create a new AWS compute connection
connection = Fog::Compute.new(
  :provider               => :aws,
  :aws_access_key_id      => node['aws_ha_chef']['aws_access_key_id'],
  :aws_secret_access_key  => node['aws_ha_chef']['aws_secret_access_key'],
  :region                 => node['aws_ha_chef']['region'],
  :endpoint               => "https://ec2.#{node['aws_ha_chef']['region']}.amazonaws.com/"
)

# Here's where we attach the IP address
connection.assign_private_ip_addresses(eth0_interface_id, { 'PrivateIpAddresses' => node['aws_ha_chef']['backend_vip']['ip_address'], 'AllowReassignment' => true })
