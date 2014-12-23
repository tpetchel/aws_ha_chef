#
# Cookbook Name:: aws_ha_chef
# Default attributes file
#
# Copyright 2014, Chef
#

# URLs to download the Chef 12 core and HA packages
node['aws_ha_chef']['urls']['core'] = 'https://web-dl.packagecloud.io/chef/stable/packages/el/6/chef-server-core-12.0.1-1.x86_64.rpm'
node['aws_ha_chef']['urls']['ha'] = 'https://web-dl.packagecloud.io/chef/stable/packages/el/6/chef-ha-1.0.0-1.x86_64.rpm'

# FQDN of your Amazon elastic load balancer
node['aws_ha_chef']['api_fqdn']                          = ''

node['aws_ha_chef']['ebs_vol_id']                        = ''
node['aws_ha_chef']['ebs_device']                        = ''

node['aws_ha_chef']['backend1']['fqdn']                  = '' 
node['aws_ha_chef']['backend1']['ip_address']            = '' 
node['aws_ha_chef']['backend2']['fqdn']                  = '' 
node['aws_ha_chef']['backend2']['ip_address']            = '' 

node['aws_ha_chef']['frontends']['fe1']['fqdn']          = ''
node['aws_ha_chef']['frontends']['fe1']['ip_address']    = ''
node['aws_ha_chef']['frontends']['fe2']['fqdn']          = ''
node['aws_ha_chef']['frontends']['fe2']['ip_address']    = ''

# Want more frontends? Add as many as you need here:
# node['aws_ha_chef']['frontends']['fe3']['fqdn'] = ''
# node['aws_ha_chef']['frontends']['fe3']['ip_address'] = ''
# node['aws_ha_chef']['frontends']['fe4']['fqdn'] = ''
# node['aws_ha_chef']['frontends']['fe4']['ip_address'] = ''

# Authorized keys file for syncing configs from backend to frontends
default['aws_ha_chef']['authorized_keys'] = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjnDoDewF6tt6zKruKxgi7jN5siOk6WbpQ/Xu+gjoiWgRuWz3QkYx5was72M3UVYEun5O+R0r1fsShd/gzsna/InncUleCLitNg92OdAEA9cX1T7Xz1X8BrRJn/l61ElSftv4mUVx9+Y5GpsQ5vOXUdHVWOgFQjNwKpo/o0jfXEotZ/d6L8/6lb4LhCUJ1H0v98ODHaSl8YHvOBpNW9eKomba1rYAr1+eqY1d/JbnduH476TObiskDmmIfVxYnGSNVSEigve4H7zqSEHQoOti4hMzJFgx5MOBoMndjdvdTFNXMHGYkyHE6E6Xm21yBJeNXyf7bWQphw9awi4qZCEof root@backend'
