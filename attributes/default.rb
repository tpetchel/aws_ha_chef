#
# Cookbook Name:: tiered-chef-server
# Default attributes file
#
# Copyright 2014, Chef
#
# All rights reserved - Do Not Redistribute
#

default['chef-server']['api_fqdn'] = 'chef.example.com'
default['chef-server']['backend']['fqdn'] = 'backend.chef-demo.com'
default['chef-server']['backend']['ipaddress'] = '192.168.155.10'

# The frontends are a hash. If you don't declare it somewhere, the hostsfile
# and backend recipes will fallback to the default demo settings.  This is
# so we can avoid a hash merge when this is used with chef solo.
default['chef-server']['frontends'] = {}

default['chef-server']['urls']['manage'] = 'http://dxev6telsiawn.cloudfront.net/private-chef/opscode-manage_1.3.1-1_amd64.deb'
default['chef-server']['urls']['push_jobs'] = 'http://dxev6telsiawn.cloudfront.net/private-chef/opscode-push-jobs-server_1.1.1-1_amd64.deb'
default['chef-server']['urls']['reporting'] = 'http://dxev6telsiawn.cloudfront.net/private-chef/opscode-reporting_1.1.1-1_amd64.deb'
default['chef-server']['urls']['private_chef'] = 'http://dxev6telsiawn.cloudfront.net/private-chef/private-chef_11.1.4-1_amd64.deb'

# Are we behind a Netscaler or F5?
default['chef-server']['load_balancer'] = false

# Authorized keys file for syncing configs from backend to frontends
default['chef-server']['authorized_keys'] = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjnDoDewF6tt6zKruKxgi7jN5siOk6WbpQ/Xu+gjoiWgRuWz3QkYx5was72M3UVYEun5O+R0r1fsShd/gzsna/InncUleCLitNg92OdAEA9cX1T7Xz1X8BrRJn/l61ElSftv4mUVx9+Y5GpsQ5vOXUdHVWOgFQjNwKpo/o0jfXEotZ/d6L8/6lb4LhCUJ1H0v98ODHaSl8YHvOBpNW9eKomba1rYAr1+eqY1d/JbnduH476TObiskDmmIfVxYnGSNVSEigve4H7zqSEHQoOti4hMzJFgx5MOBoMndjdvdTFNXMHGYkyHE6E6Xm21yBJeNXyf7bWQphw9awi4qZCEof root@backend'
