# Custom matchers for resources that don't define their own

def install_composer_project(project_path)
  ChefSpec::Matchers::ResourceMatcher.new(:composer_project, :install, project_path)
end
