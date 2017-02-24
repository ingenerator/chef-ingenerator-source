require 'spec_helper'
require_relative '../../libraries/deploy_helpers.rb'

describe Ingenerator::SourceDeployment::DeployHelpers do
  let (:my_recipe) { Class.new { extend Ingenerator::SourceDeployment::DeployHelpers } }
  let (:node) { Chef::Node.new }

  before :example do
    allow(my_recipe).to receive(:node).and_return(node)
  end

  describe 'this_deployment_path' do
    context 'when the path has not been initialised' do
      it 'raises an exception' do
        expect { my_recipe.this_release_path }.to raise_error Ingenerator::SourceDeployment::DeployHelpers::DeploymentNotReadyError
      end
    end

    context 'once path is known' do
      it 'returns the path' do
        Ingenerator::SourceDeployment::DeploymentManager.set_release_path('/path/to/code/123yd123123')
        expect(my_recipe.this_release_path).to eq('/path/to/code/123yd123123')
      end
    end
  end
end
