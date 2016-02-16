actions :create, :create_if_missing, :delete
default_action :create

attribute :artifactory_url, :kind_of => String
attribute :artifactoryonline, :kind_of => String
attribute :repository, :kind_of => String, :required => true
attribute :repository_path, :kind_of => String, :required => true
attribute :artifactory_username, :kind_of => String
attribute :artifactory_password, :kind_of => String

attribute :group, :kind_of => [Integer, String]
attribute :mode, :kind_of => [Integer, String]
attribute :owner, :kind_of => [Integer, String]
