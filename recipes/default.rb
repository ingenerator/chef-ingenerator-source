#
# Deploys application source code, either locally or for a proper deployment
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

if (node['project'] && node['project']['name'])
  node.default['project']['deploy']['destination'] = "/var/www/#{node['project']['name']}"
end

if node['project']['deploy']['type'] == :in_place
  include_recipe "ingenerator-source::deploy_in_place"

elsif node['project']['deploy']['type'] == :deploy
  include_recipe "ingenerator-source::deploy_revision"

else
  raise "Invalid deploy type #{node['project']['deploy']['type']}"
end
