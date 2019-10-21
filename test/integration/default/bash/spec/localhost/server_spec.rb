require "serverspec"

set :backend, :exec

describe file("/opt/commons-httpclient/commons-httpclient-3.1.jar") do
  it { should be_file }
end

describe file("/opt/testfile.zip") do
  it { should be_file }
end

describe file("/opt/test_file_highest.zip") do
  it { should be_file }
end