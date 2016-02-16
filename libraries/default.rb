require "base64"
require "json"
require "net/http"
require "uri"

module ArtifactoryArtifact
  module Helper
    def artifactoryonline_url(server_name)
      "https://#{server_name}.artifactoryonline.com/#{server_name}"
    end

    def artifactory_headers(options={})
      if options[:username] or options[:password]
        {
          "Authorization" => "Basic #{::Base64.encode64("#{options[:username]}:#{options[:password]}").chomp}",
        }
      else
        {}
      end
    end

    def artifactory_rest_delete(artifactory_url, headers={})
      artifactory_rest(:DELETE, artifactory_url, nil, headers)
    end

    def artifactory_rest_head(artifactory_url, headers={})
      artifactory_rest(:HEAD, artifactory_url, nil, headers)
    end

    def artifactory_rest_get(artifactory_url, headers={})
      artifactory_rest(:GET, artifactory_url, nil, headers)
    end

    def artifactory_rest_post(artifactory_url, data, headers={})
      headers = {"Content-Type" => "application/json"}.merge(headers)
      case headers["Content-Type"]
      when /\Aapplication\/json(?:;(.*))?\z/
        body = ::JSON.dump(data)
      else
        body = data
      end
      artifactory_rest(:POST, artifactory_url, body, {"Content-Type" => "application/json"}.merge(headers))
    end

    def artifactory_rest_put(artifactory_url, body, headers={})
      headers = {"Content-Type" => "application/octet-stream"}.merge(headers)
      artifactory_rest(:PUT, artifactory_url, body, headers)
    end

    def artifactory_rest(method, artifactory_url, body, headers={})
      if ::URI === artifactory_url
        uri = artifactory_url
      else
        uri = ::URI.parse(artifactory_url)
      end
      request_class = ::Net::HTTP.const_get(method.to_s.capitalize)
      request_has_body = request_class.const_get(:REQUEST_HAS_BODY) rescue false
      response_has_body = request_class.const_get(:RESPONSE_HAS_BODY) rescue false
      ::Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https") do |http|
        request = request_class.new(uri.path)
        headers.each do |key, value|
          request[key] = value
        end
        if request_has_body and body
          request.body = body
        end
        response = http.request(request)
        if ::Net::HTTPSuccess === response
          if response_has_body
            case response["Content-Type"]
            when /\Aapplication\/json(?:;(.*))?\z/, /\Aapplication\/[^;]+\+json\z/
              # e.g. "application/vnd.org.jfrog.artifactory.storage.FolderInfo+json"
              return JSON.parse(response.body) # TODO: decode bytes in given encoding
            else
              Chef::Log.warn("Artifactory REST API: warning: #{uri}: Unknown Content-Type: #{response["Content-Type"]}")
              return response.body
            end
          else
            nil
          end
        else
          raise("Artifactory REST API: error: #{uri}: #{response.inspect}")
        end
      end
    end
  end
end
