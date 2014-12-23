tiered-chef-server Cookbook
===========================
This cookbook will install and configure a tiered Chef server configuration 
with one backend server and multiple front-end servers. NOTE: the recipes 
contained in this cookbook are NOT all idempotent, nor should you be running
the Chef client on your Chef server(s). Use it as a one-off setup tool for 
building new Chef server clusters, or for restoring after a failure.

Requirements
------------
Chef server requirements are listed on the docs.opscode.com website at the 
following URLS:

http://docs.opscode.com/enterprise/install_server_pre.html

http://docs.opscode.com/enterprise/install_server_fe.html

This cookbook has been tested on Ubuntu 12.04, 64 bit.

Attributes
----------

<table>
  <tr>
    <th width='200px'>Key</th>
    <th width='100px'>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['chef-server']['api_fqdn']</tt></td>
    <td>String</td>
    <td>FQDN users will type in to reach the server.  This can be a load-balanced FQDN or one of the frontends FQDNs.</td>
    <td><tt>chef.example.com</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-server']['backend']['fqdn']</tt></td>
    <td>String</td>
    <td>FQDN of the backend server.</td>
    <td><tt>chef.example.internal</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-server']['backend']['ipaddress']</tt></td>
    <td>String</td>
    <td>IP address that the frontend servers can use to reach the backend server</td>
    <td><tt>192.168.0.100</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-server']['backend']['ipaddress']</tt></td>
    <td>String</td>
    <td>IP address that the frontend servers can use to reach the backend server</td>
    <td><tt>192.168.0.100</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-server']['frontends']</tt></td>
    <td>Hash</td>
    <td>Key/Value pairs of FQDN and IP address for each frontend server.</td>
    <td><tt>'frontend1.chef-demo.com' => '192.168.155.10'</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-server']['urls']</tt></td>
    <td>Strings</td>
    <td>Each of manage, push_jobs, reporting, and private_chef have a separate download URL attribute.</td>
    <td><tt>See default attributes file, it's fairly self-explanatory.</tt></td>
  </tr>
</table>

Usage
-----

Usage is fairly simple and straightforward.  First configure all the attributes listed above via a role, *.json file, or .kitchen.yml file. Look in the included .kitchen.yml file to see which order the recipes are in. Note also that you will need to use the 'hostsfile' recipe for local testing if you don't have 'real' DNS for your test machines.  Also note that if you are installing the reporting or push_jobs addons, you must build and configure your frontend servers first, then configure the backend server last.  This is because the backend server generates certs and other config files that get pushed up to the frontend servers at the end of the backend.rb recipe. 

The NTP recipe is only required if you don't already have a way to configure NTP.

A typical run list for a frontend server might look like this:
      - recipe[tiered-chef-server::configfile]
      - recipe[tiered-chef-server::ntp]
      - recipe[tiered-chef-server::server]
      - recipe[tiered-chef-server::manage]
      - recipe[tiered-chef-server::reporting]
      - recipe[tiered-chef-server::push_jobs]
      - recipe[tiered-chef-server::frontend]

And a typical run list for a backend server might look like this:
      - recipe[tiered-chef-server::configfile]
      - recipe[tiered-chef-server::ntp]
      - recipe[tiered-chef-server::server]
      - recipe[tiered-chef-server::reporting]
      - recipe[tiered-chef-server::push_jobs]
      - recipe[tiered-chef-server::backend]
