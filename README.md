# artifactory-artifact

LWRP for artifacts on Artifactory.

## Supported Platforms

* Debian GNU/Linux
* Ubuntu Linux

## Examples

Download artifact from Artifactory Online.

```rb
artifactory_artifact "/opt/twittersdk/twitter-core-1.6.4-javadoc.jar" do
  artifactoryonline "twittersdk"
  repository "repo"
  repository_path "com/twitter/sdk/android/twitter-core/1.6.4/twitter-core-1.6.4-javadoc.jar"
end
```

## License and Authors

Copyright 2016 Yamashita, Yuu (yuu@treasure-data.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
