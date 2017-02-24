#
# Default prepare_deploy recipe, called once the application has been checked out but before
# it is symlinked into production.
#
# Author::  Andrew Coulton (<andrew@ingenerator.com>)
# Cookbook Name:: ingenerator-source
# Recipe:: prepare_deploy
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

unless node['project']['deploy']['release_path']
  raise(
    "The prepare_deploy recipe requires the node.project.deploy.release_path attribute to be set.\n"+
    "Are you trying to include the recipe directly rather than as a deploy callback?"
  )
end
