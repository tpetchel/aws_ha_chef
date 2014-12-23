#
# Cookbook Name:: tiered-chef-server
# Libraries:: helpers
#

def server_file(uri)
  require 'pathname'
  require 'uri'
  Pathname.new(URI.parse(uri).path).basename.to_s
end
