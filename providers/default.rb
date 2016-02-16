require "uri"

def whyrun_supported?
  true
end

include ArtifactoryArtifact::Helper

def manage_resource(new_resource)
  request_headers = artifactory_headers(
    :username => new_resource.artifactory_username,
    :password => new_resource.artifactory_password,
  )

  if new_resource.artifactory_url
    artifactory_url = ::URI.parse(new_resource.artifactory_url)
  else
    if new_resource.artifactoryonline
      artifactory_url = ::URI.parse(artifactoryonline_url(new_resource.artifactoryonline))
    else
      fail("Artifactory URL is not specified")
    end
  end

  repository_path = "#{new_resource.repository.sub(/\A\/+/, "")}/#{new_resource.repository_path}"
  artifact_url = ::URI.join("#{artifactory_url}/", repository_path.sub(/\A\/+/, ""))
  storage_url = ::URI.join("#{artifactory_url}/", "api/storage/#{repository_path}")

  # Retrieve Artifact's SHA256 checksum via Artifactory REST API
  # https://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API#ArtifactoryRESTAPI-FileInfo
  artifact_sha256sum = nil
  begin
    data = artifactory_rest_get(storage_url, request_headers)
    if data["checksums"] and data["checksums"]["sha256"]
      sha256sum = data["checksums"]["sha256"]
    end
  rescue => error
    ::Chef::Log.warn(error)
  end

  directory ::File.dirname(new_resource.name) do
    recursive true
  end

  remote_file new_resource.name do
    backup false
    checksum artifact_sha256sum
    headers request_headers
    source artifact_url.to_s
    action new_resource.action

    group new_resource.group if new_resource.group
    mode new_resource.mode if new_resource.mode
    owner new_resource.owner if new_resource.owner
  end
end

action :create do
  manage_resource(new_resource)
  new_resource.updated_by_last_action(true)
end

action :create_if_missing do
  manage_resource(new_resource)
  new_resource.updated_by_last_action(true)
end

action :delete do
  manage_resource(new_resource)
  new_resource.updated_by_last_action(true)
end
