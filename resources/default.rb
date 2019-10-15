default_action :create

property :artifactory_url, :kind_of => String
property :artifactoryonline, :kind_of => String
property :repository, :kind_of => String, :required => true
property :artifact_name, :kind_of => String, :required => true
property :artifactory_username, :kind_of => String
property :artifactory_password, :kind_of => String
property :highest, :kind_of => [TrueClass, FalseClass]
property :group, :kind_of => [Integer, String]
property :mode, :kind_of => [Integer, String]
property :owner, :kind_of => [Integer, String]

action_class do
  require "uri"
  require "net/http"
  require "pp"
  require "json"

  include ::ArtifactoryArtifact::Helper


  def fetch_highest (new_resource)
    #Fetching list of artifacts from artifactory 
    url = URI("#{new_resource.artifactory_url}/api/search/aql/")
    http = Net::HTTP.new(url.host, url.port)

     request = Net::HTTP::Post.new(url)
     request["Content-Type"] = 'text/plain'
     request["Accept"] = '*/*'
     request["Host"] = "#{node['chef-artifactory-artifact']['host']}"
     request["Connection"] = 'keep-alive'
     request.basic_auth new_resource.artifactory_username, new_resource.artifactory_password 
     request.body = "items.find({\"repo\":{\"$eq\":\"   #{new_resource.repository}\"}})"

     response = http.request(request)
     parsed_json = JSON.parse(response.body)

     name_re = new_resource.artifact_name.gsub(/HIGHEST/, '([\.0-9]+)')
     puts "name_re: #{name_re}"

     #Adding Version tag to parsed_json
    parsed_json["results"].each do |res|
     output = res["name"]
     output =~ /^#{name_re}$/
     res['version'] = $1
    end
 
    #Sorting versions and picking highest value
    repos = parsed_json['results']
    versions = repos.map { |x| x.values[-1] }
    puts "---------------------------------------"
    versions = versions.reject { |item| item.nil? || item == '' }
    pp versions
    highest_version = versions.sort! { |x,y|
      Chef::Provider::Package::Yum::RPMUtils.rpmvercmp(x['version'], y['version'])
    } 
    highest_version = highest_version.last
    puts "---------------------------------------"
    pp highest_version
    highest_versioned_artifact = repos.find {|h1| h1['version']==highest_version}['name']
    puts "-------------------------------------------------------------------------------------------------------------"
    puts "Highest versioned artifact is #{highest_versioned_artifact}"
    puts "-------------------------------------------------------------------------------------------------------------"
    new_resource.artifact_name = "/#{highest_versioned_artifact}"
  end 

  def manage_resource(new_resource)
    if new_resource.highest 
     fetch_highest(new_resource)
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

    artifact_name = "#{new_resource.repository.sub(/\A\/+/, "")}/#{new_resource.artifact_name}"
    artifact_url = ::URI.join("#{artifactory_url}/", artifact_name.sub(/\A\/+/, ""))
    storage_url = ::URI.join("#{artifactory_url}/", "api/storage/#{artifact_name}")

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
