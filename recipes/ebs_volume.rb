#
# Cookbook Name:: aws_ha_chef
# Recipe:: configure_ebs_volume
#

# This recipe will *not* work with the Chef 12 client, due to an issue with
# the LVM cookbook:  https://www.chef.io/blog/page/2/
# Use the Chef 11.16.4 client instead to bootstrap your chef servers.

# We have to run most of these during the compile phase, to make sure the 
# EBS volume is created and properly mounted before the execute phase.

include_recipe 'lvm::default'
include_recipe 'aws::default'

package 'lvm2' do
  action :install
end.run_action(:install)

chef_gem 'di-ruby-lvm' do
  action :install
end.run_action(:install)

gems = { "di-ruby-lvm-attrib" => "0.0.16", "open4" => "1.3.4", "di-ruby-lvm" => "0.1.3" }
gems.each do |gem, version|
  gem_package gem do
    gem_binary('/opt/chef/embedded/bin/gem')
    action :install
    # in case you want to store them locally
    # source "#{Chef::Config[:file_cache_path]}/#{gem}-#{version}.gem"
  end.run_action(:install)
end

e = aws_ebs_volume 'chef_ebs_volume' do
  aws_access_key node['aws_ha_chef']['aws_access_key_id']
  aws_secret_access_key node['aws_ha_chef']['aws_secret_access_key']
  size 100
  device "/dev/xvdj"
  volume_type "io1"
  piops 3000
  action [ :create, :attach ]
end

e.run_action(:create)
e.run_action(:attach)

lvm_volume_group 'chef' do
  physical_volumes ['/dev/xvdj'] do
    action :create
  end

  logical_volume 'data' do
    size        '85%VG'
    filesystem  'ext4'
    mount_point '/var/opt/opscode/drbd/data'
  end
end.run_action(:create)

ruby_block 'store_ebs_volume_id' do
  block do
    node.run_state['ebs_volume_id'] = node['aws']['ebs_volume']['chef_ebs_volume']['volume_id']
    Chef::Log.info("The node.run_state['ebs_volume_id'] is: #{node.run_state['ebs_volume_id']}")
  end
end
