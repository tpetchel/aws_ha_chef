# encoding: UTF-8
require 'chefspec'
require 'chefspec/berkshelf'

def gem_available?(name)
  Gem::Specification.find_by_name(name)
rescue Gem::LoadError
  false
rescue
  Gem.available?(name)
end

# These are required to work around some oddress
# Required for Growl notifications to work properly.
if gem_available?('safe_yaml')
  SafeYAML::OPTIONS[:deserialize_symbols] = true
  SafeYAML::OPTIONS[:default_mode] = 'unsafe'
end

RSpec.configure do |config|
  config.tty = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
