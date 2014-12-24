#
# Cookbook Name:: aws_ha_chef
# Recipe:: configure_ebs_volume
#

# This recipe will *not* work with the Chef 12 client, due to an issue with
# the LVM cookbook:  https://www.chef.io/blog/page/2/
# Use the Chef 11.16.4 client instead to bootstrap your chef servers.

include_recipe 'lvm::default'
include_recipe 'aws::default'

gems = { "di-ruby-lvm-attrib" => "0.0.16", "open4" => "1.3.4", "di-ruby-lvm" => "0.1.3" }
gems.each do |gem, version|
  gem_package gem do
    gem_binary('/opt/chef/embedded/bin/gem')
    action :install
    # in case you want to store them locally
    # source "#{Chef::Config[:file_cache_path]}/#{gem}-#{version}.gem"
  end
end

aws_ebs_volume 'chef_ebs_volume' do
  aws_access_key node['aws_ha_chef']['aws_access_key_id']
  aws_secret_access_key node['aws_ha_chef']['aws_secret_access_key']
  size 100
  device "/dev/xvdj"
  volume_type "io1"
  piops 3000
  action [ :create, :attach ]
end

lvm_volume_group 'chef' do
  physical_volumes ['/dev/xvdj']

  logical_volume 'data' do
    size        '85%VG'
    filesystem  'ext4'
    mount_point '/var/opt/opscode/drbd/data'
  end
end

node.run_state['ebs_volume_id'] = node['aws']['ebs_volume']['chef_ebs_volume']['volume_id']

log "The EBS volume ID is: #{node.run_state['ebs_volume_id']}"

#execute 'store_ebs_volume_id' do
#  command "echo #{node['aws']['ebs_volume']['chef_ebs_volume']['volume_id']} > #{Chef::Config[:file_cache_path]}/ebs_volume_id"
#end
