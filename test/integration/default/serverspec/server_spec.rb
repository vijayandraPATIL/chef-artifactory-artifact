require "serverspec"

set :backend, :exec

describe file("/opt/twittersdk/twitter-core-1.6.4-javadoc.jar") do
  it { should be_file }
end
