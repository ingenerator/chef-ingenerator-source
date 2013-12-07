name 'ingenerator-source'
maintainer 'Andrew Coulton'
maintainer_email 'andrew@ingenerator.com'
license 'Apache 2.0'
description 'Manages deployment and provisioning of project source code on an instance, either live or VM'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

%w(ubuntu).each do |os|
  supports os
end

depends 'composer'
