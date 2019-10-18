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
artifactory_artifact "/opt/common-httpclient.zip" do
  artifactoryonline "grails"
  repository "core"
  artifact_name "commons-httpclient-HIGHEST.zip"
  highest true
  owner "root"
  group "root"
  mode "0644"
end
