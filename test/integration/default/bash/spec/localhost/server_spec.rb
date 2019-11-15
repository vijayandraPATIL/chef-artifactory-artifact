require "serverspec"
require 'json'

set :backend, :exec

describe file("/opt/commons-httpclient/commons-httpclient-3.1.jar") do
  it { should be_file }
end

node = JSON.parse(IO.read('/tmp/kitchen_chef_node.json'))
if node['artifactory_url']
  describe file('/opt/testfile.zip') do
    it { should be_file }
  end

  describe file('/opt/test_file_highest.zip') do
    it { should be_file }
  end
end
