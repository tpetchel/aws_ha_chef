name             'aws_ha_chef'
maintainer       'Chef'
maintainer_email 'scarolan@chef.io'
license          'All rights reserved'
description      'Installs an HA Chef cluster in AWS EC2'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'
depends          'lvm'
depends          'aws'
