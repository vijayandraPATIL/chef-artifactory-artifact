default_action :create

property :artifactory_url, :kind_of => String
property :artifactoryonline, :kind_of => String
property :repository, :kind_of => String, :required => true
property :repository_path, :kind_of => String, :required => true
property :artifact_name, :kind_of => String
property :artifactory_username, :kind_of => String
property :artifactory_password, :kind_of => String
property :fetch_highest, :kind_of => [TrueClass, FalseClass]

property :group, :kind_of => [Integer, String]
property :mode, :kind_of => [Integer, String]
property :owner, :kind_of => [Integer, String]

action_class do
  require "uri"
  require 'net/http'
  require 'json'

  include ::ArtifactoryArtifact::Helper

  def fetching_highest(new_resource)

    if new_resource.artifact_name.nil?
      raise Chef::Exceptions::ValidationFailed, "artifact_name is a required property, when fetch_highest is set true"
    end

    # Fetching list of artifacts from artifactory
    url = URI("#{new_resource.artifactory_url}/api/search/aql/")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url)

    request['Content-Type'] = 'text/plain'
    request['Accept'] = '*/*'
    request['Host'] = url.host
    request['Connection'] = 'keep-alive'
    request.basic_auth new_resource.artifactory_username, new_resource.artifactory_password
    request.body = "items.find({\"repo\":{\"$eq\":\"   #{new_resource.repository}\"}})"
    response = http.request(request)
    
    unless response.kind_of? Net::HTTPSuccess
      Chef::Log.error(response.body)
      raise Chef::Exceptions::InvalidSearchQuery , "Artifactory Search Failed"
    end

    parsed_json = JSON.parse(response.body)
    name_re = new_resource.artifact_name.gsub(/HIGHEST/, '([\.0-9]+)')

    # Adding Version tag to parsed_json
    parsed_json['results'].each do |res|
      output = res['name']
      output =~ /^#{name_re}$/
      res['version'] = $1
    end

    #Sorting versions and picking highest value
    parsed_json['results'].sort! { |x,y|
      Chef::Provider::Package::Yum::RPMUtils.rpmvercmp(x['version'], y['version'])
    }
    highest = parsed_json['results'].last
    new_resource.repository_path = "#{highest['path']}/#{highest['name']}"
  end

  def manage_resource(new_resource)
    if new_resource.fetch_highest
      fetching_highest(new_resource)
    end

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
end

action :create do
  manage_resource(new_resource)
end

action :create_if_missing do
  manage_resource(new_resource)
end

action :delete do
  manage_resource(new_resource)
end
