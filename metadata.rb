name 'ingenerator-source'
maintainer 'Andrew Coulton'
maintainer_email 'andrew@ingenerator.com'
license 'Apache-2.0'
chef_version '>=12.18.31'
description 'Manages deployment and provisioning of project source code on an instance, either live or VM'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
issues_url 'https://github.com/ingenerator/chef-ingenerator-source/issues'
source_url 'https://github.com/ingenerator/chef-ingenerator-source'
version '2.0.0'

%w(ubuntu).each do |os|
  supports os
end
