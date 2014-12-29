aws_ha_chef Cookbook
===========================
This cookbook will install and configure a high-availability Chef server cluster in AWS EC2 with two back end servers and and multiple front end servers.

This cookbook attempts to automate most of the steps in the installation guide. Official installation documentation is here: https://docs.chef.io/install_server_ha_aws.html

The front end servers and secondary back end server need configs that are generated on the primary back end machine. We work around this in the primary recipe by creating a *.tar.gz bundle for each of the core server and reporting configs, and then serving them up on a lightweight web server on port 31337. The 'cluster' recipe will try to pull this file for about 30 minutes before giving up. This means you can bring up the entire cluster in parallel, and the front ends and secondary back end machine will simply wait until the primary back end is ready. You may use Chef Zero or Chef Provisioning to deploy your cluster. A .kitchen.yml file is also supplied for Test Kitchen users.

The push_jobs, reporting, and manage UI plugins are all installed automatically. You should only need to call these three recipes directly:

frontend - for your front end servers
secondary - for the secondary back end server
primary - for the primary back end server

Requirements
------------
NOTE: If you want to use the .kitchen.yml file that comes with this cookbook, you must use my fork of the kitchen-ec2 driver, at least until my pull request to add static IP address support is merged. You can check out my fork and the private_ip_address branch here:

https://github.com/scarolan/kitchen-ec2/tree/add_private_ip 

Instructions to build your own kitchen-ec2 gem to work with the ChefDK are below.

```
chef gem uninstall kitchen-ec2
git clone https://github.com/scarolan/kitchen-ec2
cd kitchen-ec2
git checkout add_private_ip
gem build kitchen-ec2.gemspec
chef gem install kitchen-ec2-0.8.1.dev.gem
```

These are example settings that will work with the default attributes in the cookbook. You can also create your own subnet and security group settings, as long as the necessary ports between the front end and back end servers are open. See this link for the ports that are required by the Chef server:

https://docs.chef.io/server_firewalls_and_ports.html 

Default settings - HA Chef cluster in us-west-2 (Oregon) region:
+ VPC: CHEF_HA_VPC  172.25.0.0/16
+ Subnets:  Each subnet is attached to an availability zone. Make sure you enable "Auto-Assign Public IP" on each subnet so you can reach your instances!
  - us-west-2a 172.25.10.0/24
  - us-west-2b 172.25.20.0/24
  - us-west-2c 172.25.30.0/24 
+ Security groups for load balancer, front end, back end and VPC default. All four of these security groups allow unrestricted outbound access by default.
  - Default - allows only inbound port 22, and ICMP requests (for ping testing)
  - CHEF_LB - allows ports 80 and 443 tcp.
  - CHEF_VPC_Backend - Allows all traffic from both front ends and back ends
  - CHEF_VPC_Frontend - Allows 80 and 443 tcp from the load balancer security group
+ Internet gateway on Chef VPC network, so subnets can reach the internet. Don't forget to attach this to the VPC or your machines won't be able to reach the outside world.
+ EBS storage device, recommended size 100GB and provisioned 3000 IOPS. You can either create this by hand or use the ebs_volume recipe to have Chef create it for you. Just make sure that if you create it by hand, you specify the volume id in your node attributes.
+ IAM account with correct rights; see below for example. You'll want to create a restricted account because its AWS keys are going to reside on the back-end servers in a config file that is owned by root. This user handles the VIP address and the storage device for the back-end servers. Note that the user's AWS keys are stored as attributes. These will be rendered into the chef-server.rb config file once the configfile recipe is run
+ Either an internal or external load balancer to expose the Chef API. You should add all your frontends to the load balancer once they are up and running. This must be done by hand. Or via the AWS command line tools. We may add a recipe to automate this in the future. You can use https and /signup for the health check URL. The load balancer should have listeners on port 80 (http) and tcp port 443 (do not choose SSL or HTTPS! We terminate SSL on the Chef Server, not at the load balancer.)
+ Two back end instances, two or more front end instances.
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

default['aws_ha_chef']['region']                   Region your cluster will be installed in

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

Usage is fairly simple and straightforward. First configure all the attributes listed above via a role, *.json file, or .kitchen.yml file. The NTP recipe is only required if you don't already have a way to configure NTP.

Sample IAM Account Settings
-----

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1419361552000",
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateVolume",
        "ec2:DescribeVolumeAttribute",
        "ec2:DescribeVolumeStatus",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:EnableVolumeIO",
        "ec2:ImportVolume",
        "ec2:ModifyVolumeAttribute",
        "ec2:DescribeNetworkInterfaces",
        "ec2:AssignPrivateIpAddresses",
        "ec2:UnassignPrivateIpAddresses"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
```
