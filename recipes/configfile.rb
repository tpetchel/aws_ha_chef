#
# Cookbook Name:: aws_ha_chef
# Recipe:: configfile
#

ruby_block 'get_ebs_volume_id' do
  block do
    if node['aws_ha_chef']['ebs_volume_id'] == ''
      # Use the ebs_volume recipe to auto-create the EBS volume
      $ebs_vol_id = node.run_state['ebs_volume_id']
      $ebs_vol_id = node['aws']['ebs_volume']['chef_ebs_volume']['volume_id']
    else
      # Or if you prefer, configure it and attach it manually
      # Just set the node attribute below to your vol-XXXXXXX id
      $ebs_vol_id = node['aws_ha_chef']['ebs_volume_id']
    end
  end
end

# Make sure /etc/opscode exists
directory '/etc/opscode' do
  action :create
  owner 'root'
  group 'root'
  mode '0644'
end

# Render the chef-server.rb config file
template '/etc/opscode/chef-server.rb' do
  action :create
  source 'chef-server.erb'
  owner 'root'
  group 'root'
  variables(
    lazy {
      {:ebs_volume_id => $ebs_vol_id}
    }
  )
  mode '0644'
end
