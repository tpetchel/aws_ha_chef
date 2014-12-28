aws_ha_chef Cookbook
===========================
This cookbook will install and configure a high-availability Chef server cluster with two back end servers and and multiple front-end servers.

NOTE: the recipes contained in this cookbook are NOT all idempotent, nor should you be running the Chef client on your Chef server(s). Use it as a one-off setup tool for building new Chef server clusters, or for restoring after a failure.

IMPORTANT: If you wish to use the cluster recipe to configure the entire cluster, you must have passwordless ssh access from the primary back-end to all other hosts. You can use the add\_ssh\_key recipe to enable the cluster recipe which will clean up the temporary ssh key when it's done. You can also use the remove\_ssh\_key recipe to purge it from your machines.

Requirements
------------
TODO: Add requirements here.

These are example settings that will work with the default attributes in the cookbook. You can also create your own subnet and security group settings, as long as the necessary ports between the front end and back end servers are open. See this link for the ports that are required by the Chef server:

https://docs.chef.io/server_firewalls_and_ports.html 

Default settings - HA Chef cluster in us-west-2 (Oregon) region:
+ VPC: 
  CHEF_HA_VPC  172.25.0.0/16
+ Subnets:  Each subnet is attached to an availability zone:
  us-west-2a 172.25.10.0/24
  us-west-2b 172.25.20.0/24
  us-west-2c 172.25.30.0/24 
+ Security groups for load balancer, front end, back end and VPC default
  - Default - allows only inbound port 22, and ICMP requests (for ping testing)
  - CHEF_LB - allows ports 80 and 443 tcp.
  - CHEF_VPC_Backend - Allows all traffic from front ends
  - CHEF_VPC_Frontend - Allows 80 and 443 tcp from the load balancer security group

  All four of these security groups allow unrestricted outbound access by default.

+ Internet gateway on Chef VPC network, so subnets can reach the internet.  Don't forget to attach this or your machines won't be able to reach the outside world.
+ EBS storage device, recommended size 100GB and provisioned 3000 IOPS.  You can either create this by hand or use the ebs_volume recipe to have Chef create it for you.  Just make sure that if you create it by hand, you specify the volume id in your node attributes.
+ IAM account with correct rights; see installation guide. You'll want to create a restricted account because its AWS keys are going to reside on the back-end servers in a config file that is owned by root. This user handles the VIP address and the storage device for the back-end servers.
+ Either an internal or external load balancer to expose the Chef API
+ Two back end instances, two or more front-end instances
  - Back end servers must both be in the same availability zone
  - Back end EBS storage must be in the same AZ as the back end servers
  - Front end servers can be in any availability zone in the same region
  - You must create VPC subnets in any AZ where you want to put servers (see above)
  - The default settings in this cookbook create a pair of m3.medium instances in us-west-2a for the back ends and one front end in each of us-west-2a, 2b, and 2c.
+ OPTIONAL: Routes and/or peering connections for any internal networks


Attributes
----------

```
default['aws_ha_chef']['api_fqdn']                 FQDN of your Amazon elastic load balancer
default['aws_ha_chef']['ebs_volume_id']            EBS volume id.  Create and attach your own, or use the ebs_volume recipe to create one. 
default['aws_ha_chef']['ebs_device']               Device ID of the ebs_device.  Default is /dev/xvdj

default['aws_ha_chef']['backend_vip']['fqdn']      FQDN of the backend VIP.  Defaults to backend-vip
default['aws_ha_chef']['backend_vip']['ip_address'] IP address of the backend VIP. 

default['aws_ha_chef']['backend1']['fqdn']         FQDN of the primary back end
default['aws_ha_chef']['backend1']['ip_address']   IP address of the primary back end
default['aws_ha_chef']['backend2']['fqdn']         FQDN of the secondary back end 
default['aws_ha_chef']['backend2']['ip_address']   IP address of the secondary back end

default['aws_ha_chef']['frontends']['fe1']['fqdn']        FQDN of front end 1
default['aws_ha_chef']['frontends']['fe1']['ip_address']  IP address of front end 1
default['aws_ha_chef']['frontends']['fe2']['fqdn']        FQDN of front end 2
default['aws_ha_chef']['frontends']['fe2']['ip_address']  IP address of front end 2
default['aws_ha_chef']['frontends']['fe3']['fqdn']        FQDN of front end 3
default['aws_ha_chef']['frontends']['fe3']['ip_address']  IP address of front end 3

# Want more frontends? Add as many as you need here:
# default['aws_ha_chef']['frontends']['fe4']['fqdn']        FQDN of front end 4
# default['aws_ha_chef']['frontends']['fe4']['ip_address']  IP address of front end 4
```


Usage
-----

Usage is fairly simple and straightforward.  First configure all the attributes listed above via a role, *.json file, or .kitchen.yml file. Look in the included .kitchen.yml file to see which order the recipes are in. Note also that you will need to use the hosts recipe for local testing if you don't have DNS for your test machines.  Use the add_ssh_key and cluster recipes to configure the HA cluster.  add_ssh_key goes on all machines, cluster should only be run from the primary back-end

The NTP recipe is only required if you don't already have a way to configure NTP.

