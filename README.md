inGenerator Source cookbook
=================================
[![Build Status](https://travis-ci.org/ingenerator/chef-ingenerator-source.png?branch=master)](https://travis-ci.org/ingenerator/chef-ingenerator-source)

The `ingenerator-source` cookbook provides a standard framework to manage deployment and provisioning of project source
code on an instance. This is used either for atomic checkouts on a live instance, or for running the same provisioning
and build code for a checkout on a development VM or build server.

Requirements
------------
- Chef 11 or higher
- **Ruby 1.9.3 or higher**

Installation
------------
We recommend adding to your `Berksfile` and using [Berkshelf](http://berkshelf.com/):

```ruby
cookbook 'ingenerator-source', git: 'git://github.com/ingenerator/chef-ingenerator-source', branch: 'master'
```

Have your main project cookbook *depend* on ingenerator-source by editing the `metadata.rb` for your cookbook.

```ruby
# metadata.rb
depends 'ingenerator-source'
```

Usage
-----
There's probably a fair bit of 'deployment' you still need to do on a local VM to get it up and running. You may need to
build assets, provision config files with details of database and API services, install composer dependencies etc. Much
of this provisioning is likely to overlap with the deployment/provisioning workflow on a live or build server. So this
cookbook wraps both types of operations together to make it easy to share details between both.

Your runlist just needs to include the `ingenerator-source::default` recipe and the rest of the process is controlled by
attributes.

### `:in_place` provisioning - eg on a VM

With in-place provisioning, the recipe simply creates a symlink from your deploy destination to the source path you
specify. There are no revision checkout folders, and if the source path is a vagrant share or similar you'll have a live
checkout. Once the symlink is in place the post-deploy hooks will execute as though following a deploy.

| attribute                                | default                         | notes                                   |
|------------------------------------------|---------------------------------|-----------------------------------------|
| node['project']['deploy']['type']        |                                 | set to `:in_place` to trigger this mode |
| node['project']['deploy']['source']      | /vagrant                        | the location of your raw source files   |
| node['project']['deploy']['destination'] | /var/www/{project_name}/current | the base web path for your application  |

### `:deploy` - eg on a build or live server

This is the default action.

The standard workflow is to check out the revision you want in a source repository on the instance - to get up to date
versions of the provisioning scripts etc - and then allow this cookbook to deploy a known checkout from there to the
web root using the chef deploy resource. Again, post-deploy hooks will execute at key points in the process.

| attribute                                | default                         | notes                                     |
|------------------------------------------|---------------------------------|-------------------------------------------|
| node['project']['deploy']['type']        | :deploy                         | set to `:deploy` to trigger this mode     |
| node['project']['deploy']['force']       | false                           | whether to force a redeploy of same rev   |
| node['project']['deploy']['source']      | /var/www/www-source             | the location of your raw source files     |
| node['project']['deploy']['destination'] | /var/www/{project_name}/current | the base web path for your application    |
| node['project']['deploy']['revision']    | HEAD                            | you should checkout the desired rev first |


### Deployment hooks

You can provide ruby scripts with deployment hooks to run before the checked out code is symlinked into production (or
at the end of the process for an in-place deploy). These have full access to recipes, resources and the rest of the
chef environment, but note that they are *not* loaded until during the deployment so they cannot include changes to
attributes, runlists etc that need to apply outside their own scope.

As we use a simplified set of deploy commands, the most useful hooks are likely to be `before_symlink` and
`after_restart`.

If you don't provide your own callbacks then by default the cookbook just checks for a composer.json and if found
installs your vendors - note that you will need to re-implement this if you add a custom hook.

```ruby
 # Place the path from the root of your checkout into your attributes file
 default['project']['deploy']['before_symlink'] = 'architecture/deploy_hooks/before_symlink.rb'

 # architecture/deploy_hooks/before_symlink.rb
 composer_project release_path do
   run_as  node['apache']['user']
   dev     node['project']['install_dev_tools']
   quiet   false
   action  [:install]
 end
```

You can obviously make steps within your callbacks conditional on node attributes, etc, if required.

### Testing
See the [.travis.yml](.travis.yml) file for the current test scripts.

Contributing
------------
1. Fork the project
2. Create a feature branch corresponding to your change
3. Create specs for your change
4. Create your changes
4. Create a Pull Request on github

License & Authors
-----------------
- Author:: Andrew Coulton (andrew@ingenerator.com)

```text
Copyright 2012-2013, inGenerator Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
