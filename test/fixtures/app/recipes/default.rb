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
  artifactoryonline "grails"
  repository "core"
  artifact_name "commons-httpclient-HIGHEST.zip"
  highest true
  owner "root"
  group "root"
  mode "0644"
end
