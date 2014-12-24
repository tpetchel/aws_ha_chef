#
# Cookbook Name:: aws_ha_chef
# Recipe:: disable-iptables
#

service 'iptables' do
  action [ :stop, :disable ]
end
