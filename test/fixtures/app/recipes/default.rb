artifactory_artifact "/opt/commons-httpclient/commons-httpclient-3.1.jar" do
  artifactoryonline "grails"
  repository "core"
  repository_path "apache-httpclient/commons-httpclient/3.1/commons-httpclient-3.1.jar"
  owner "root"
  group "root"
  mode "0644"
end


# Testing to fetch highest versioned artifact from Artifactory
# I have tested this from my end and it works fine , any tester can do as long as they have an internal Artifactory.
artifactory_artifact "/opt/test_file_highest.zip" do
  artifactory_url node['artifactory_url']
  repository node['repository']
  artifact_name node['artifact_name']
  highest true
  artifactory_username node['artifactory_username']
  artifactory_password node['artifactory_password']
  owner "root"
  group "root"
  mode "0644"
end

#testing to fetch highest versioned artifact from artifactory
artifactory_artifact "/opt/testfile.zip" do
  artifactory_url node['artifactory_url']
  repository node['repository']
  repository_path node['repository_path']
  artifactory_username node['artifactory_username']
  artifactory_password node['artifactory_password']
  owner "root"
  group "root"
  mode "0644"
end
