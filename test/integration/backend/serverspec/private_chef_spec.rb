require 'spec_helper'

describe command('private-chef-ctl test') do
  it { should return_exit_status 0 }
end
