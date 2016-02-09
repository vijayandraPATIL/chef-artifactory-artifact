require "base64"
require "open-uri"
require "uri"

def whyrun_supported?
  true
end

if new_resource.artifactory_username or new_resource.artifactory_password
  artifactory_headers = {
    "Authorization" => "Basic #{::Base64.encode64("#{new_resource.artifactory_username}:#{new_resource.artifactory_password}")}",
  }
else
  artifactory_headers = {}
end

if new_resource.artifactory_url
  artifactory_uri = ::URI.parse(new_resource.artifactory_url)
else
  if new_resource.artifactoryonline
    artifactory_url = ::URI.parse("https://#{new_resource.artifactoryonline}.artifactoryonline.com/#{new_resource.artifactoryonline}/")
  else
    fail("Artifactory URL is not specified")
  end
end

repository_path = "#{new_resource.repository.sub(/\A\/+/, "")}/#{new_resource.repository_path}"
artifact_uri = ::URI.join("#{artifactory_url}/", repository_path.sub(/\A\/+/, ""))
storage_uri = ::URI.join("#{artifactory_url}/", "api/storage/#{repository_path}")

# Retrieve Artifact's SHA256 checksum via Artifactory REST API
# https://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API#ArtifactoryRESTAPI-FileInfo
artifact_sha256sum = nil
begin
  storage_uri.open(artifactory_headers) do |response|
    code, reason = response.status
    if code.to_i == 200
      data = ::JSON.parse(resp.read)
      if data["checksums"] and data["checksums"]["sha256"]
        sha256sum = data["checksums"]["sha256"]
      end
    else
      fail("Artifactory REST API error: #{storage_uri}: #{code} #{reason}")
    end
  end
rescue => error
  ::Chef::Log.warn(error)
end

remote_file new_resource.name do
  backup false
  checksum artifact_sha256sum
  headers artifactory_headers
  source artifact_url
  action new_resource.action
end
