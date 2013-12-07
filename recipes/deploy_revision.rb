#
# Runs the chef deployment resource and triggers any post-deploy handlers
#
# Author::  Andrew Coulton (<andrew@ingenerator.com>)
# Cookbook Name:: ingenerator-source
# Recipe:: default
#
# Copyright 2012-13, inGenerator Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Default deploy source for this kind of deployment
node.default['project']['deploy']['source'] = '/var/www/www-source'

# Do not allow known unstable branches into production
if File.exists?(node['project']['deploy']['source']+'/PROD_RELEASE_BLOCKER')
  if node['project']['deploy']['allow_blocked_branch']
    Chef::Log.warn('You are deploying a blocked branch - check the PROD_RELEASE_BLOCKER')
  else
    raise "Cannot deploy to production with a PROD_RELEASE_BLOCKER file - investigate and remove to continue"
  end
end

# Ensure deploy working directories exist
%w(releases shared).each do | path |
  directory "#{node['project']['deploy']['destination']}/#{path}" do
    recursive true
    owner     node['project']['deploy']['owner']
    group     node['project']['deploy']['group']
    mode      0755
  end
end

# Prevent hardlink problems with changing upstream references
directory "#{node['project']['deploy']['destination']}/shared/cached-copy" do
  action :delete
end

deploy(node['project']['deploy']['destination']) do
  repo     node['project']['deploy']['source']
  action   (node['project']['deploy']['force'] ? :force_deploy : :deploy)
  revision node['project']['deploy']['revision']

  user     node['project']['deploy']['owner']
  group    node['project']['deploy']['group']

  # Clear this default railsy configuration, manage it in hooks
  symlink_before_migrate({})
  symlinks({})
  create_dirs_before_symlink []
  purge_before_symlink []

end
