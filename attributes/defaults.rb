#
# Author:: Andrew Coulton(<andrew@ingenerator.com>)
# Cookbook Name:: ingenerator-source
# Attribute:: defaults
#
# Copyright 2012-13, Opscode, Inc.
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


default['project']['deploy']['type']                 = :deploy
default['project']['deploy']['force']                = false
# This will be reset by the default recipe if a project.name attribute is present
default['project']['deploy']['destination']          = '/var/www/ingenerator-project'
# This will be set by the appropriate deploy recipe
default['project']['deploy']['source']               = nil

default['project']['deploy']['owner']                = 'www-data'
default['project']['deploy']['group']                = 'www-data'

default['project']['deploy']['allow_blocked_branch'] = false

