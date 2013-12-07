#
# Creates a symlink from the web root to the source location and runs the post-deploy callbacks
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
node.default['project']['deploy']['source'] = '/vagrant'

directory node['project']['deploy']['destination'] do
  recursive true
  user      node['project']['deploy']['owner']
  group     node['project']['deploy']['group']
  mode      0755
end

node.override['project']['deploy']['release_path'] = node['project']['deploy']['destination']+'/current'
link node['project']['deploy']['release_path'] do
  to    node['project']['deploy']['source']
  user  node['project']['deploy']['owner']
  group node['project']['deploy']['group']
end

# Run the deploy hooks
include_recipe node['project']['deploy']['on_prepare']
include_recipe node['project']['deploy']['on_complete']
