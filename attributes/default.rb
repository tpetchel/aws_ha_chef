#
# Cookbook Name:: aws_ha_chef
# Default attributes file
#
# Copyright 2014, Chef
#

# URLs to download the Chef 12 core and HA packages
default['aws_ha_chef']['urls']['core'] = 'https://web-dl.packagecloud.io/chef/stable/packages/el/6/chef-server-core-12.0.1-1.x86_64.rpm'
default['aws_ha_chef']['urls']['ha'] = 'https://web-dl.packagecloud.io/chef/stable/packages/el/6/chef-ha-1.0.0-1.x86_64.rpm'

# Credentials of your IAM user, for managing storage and floating IP
# Best to store these in a secure place, and call from ENV variables
# Or inject them in using test kitchen. These will be rendered into
# the /etc/opscode/chef-server.rb template. Don't use your personal account
# or the root account for these!
default['aws_ha_chef']['aws_access_key_id']                 = ''
default['aws_ha_chef']['aws_secret_access_key']             = ''

# Used by the floating_ip recipe
default['aws_ha_chef']['region']                            = 'us-west-2'

# FQDN of your Amazon Elastic Load Balancer
# Hand-crafted artisinal load balancer
# Make sure you change this to match *your* load balancer:
default['aws_ha_chef']['api_fqdn']                          = 'chef-aws-ha-demo-256394054.us-west-2.elb.amazonaws.com'

# EBS storage device
# If you manually created the EBS volume, put it's vol- id here
# Otherwise you can use the ebs_volume recipe to auto-generate one.
# We recommend you just let the recipe do it for you.
default['aws_ha_chef']['ebs_volume_id']                     = ''
default['aws_ha_chef']['ebs_device']                        = '/dev/xvdj'

# We are being quite prescriptive about what IP addresses and hostnames here.
# You'll need to configure your VPC and subnet settings to match what's below
# if you want to use these defaults. You can of course create your own subnets
# and hostnames if you wish. All of these hostnames will be put into the
# /etc/hosts file on all machines in the cluster, so you don't need to worry
# too much about DNS, at least for internal communication in the cluster.

# Backend servers.  Must be in same availability zone, for example: us-west-2b
default['aws_ha_chef']['backend1']['fqdn']                  = 'backend1.example.local'
default['aws_ha_chef']['backend1']['ip_address']            = '172.25.10.98'
default['aws_ha_chef']['backend2']['fqdn']                  = 'backend2.example.local'
default['aws_ha_chef']['backend2']['ip_address']            = '172.25.10.99'

# Shared VIP address for the backend servers
default['aws_ha_chef']['backend_vip']['fqdn']               = 'backend-vip.example.local'
default['aws_ha_chef']['backend_vip']['ip_address']         = '172.25.10.200'

# Put your frontends in different availability zones if you wish
# The 172.25.10.0/24 subnet is in us-west-2a
default['aws_ha_chef']['frontends']['fe1']['fqdn']          = 'frontend1.example.local'
default['aws_ha_chef']['frontends']['fe1']['ip_address']    = '172.25.10.125'
# The 172.25.20.0/24 subnet is in us-west-2b
default['aws_ha_chef']['frontends']['fe2']['fqdn']          = 'frontend2.example.local'
default['aws_ha_chef']['frontends']['fe2']['ip_address']    = '172.25.20.125'
# The 172.25.30.0/24 subnet is in us-west-2b
default['aws_ha_chef']['frontends']['fe3']['fqdn']          = 'frontend3.example.local'
default['aws_ha_chef']['frontends']['fe3']['ip_address']    = '172.25.30.125'

# Want more frontends? Add as many as you need:
# default['aws_ha_chef']['frontends']['fe4']['fqdn']          = 'frontend4.example.local'
# default['aws_ha_chef']['frontends']['fe4']['ip_address']    = '172.25.40.125'
