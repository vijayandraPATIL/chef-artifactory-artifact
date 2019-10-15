artifactory_artifact "/opt/commons-httpclient/commons-httpclient-3.1.jar" do
  artifactoryonline "grails"
  repository "core"
  repository_path "apache-httpclient/commons-httpclient/3.1/commons-httpclient-3.1.jar"
  owner "root"
  group "root"
  mode "0644"
end


#testing to fetch highest versioned artifact from artifactory
artifactory_artifact "/path/reponame.zip" do
  artifactory_url ""
  repository ""
  artifact_name "XYZ-HIGHEST.zip"
  highest true
  artifactory_username ""
  artifactory_password ""
end