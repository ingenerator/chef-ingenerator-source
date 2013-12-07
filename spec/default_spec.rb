require 'spec_helper'

describe 'ingenerator-source::default' do
  let (:chef_run) { ChefSpec::Runner.new.converge described_recipe }

  context 'by default' do
    it "uses the full deployment recipe" do
      chef_run.node['project']['deploy']['type'].should be(:deploy)
    end

    it "sets the deploy destination to /var/www/{project_name}" do
      chef_run = ChefSpec::Runner.new do |node|
        node.set['project']['name'] = 'thisproject'
      end.converge(described_recipe)

      chef_run.node['project']['deploy']['destination'].should eq('/var/www/thisproject')
    end
  end

  context 'when node[project][deploy] is :in_place' do
    let (:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set['project']['deploy']['type'] = :in_place
      end.converge(described_recipe)
    end

    it 'should run the deploy_in_place recipe' do
      chef_run.should include_recipe 'ingenerator-source::deploy_in_place'
    end
  end

  context 'when node[project][deploy] is :deploy' do
    let (:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set['project']['deploy']['type'] = :deploy
      end.converge(described_recipe)
    end

    it 'should run the deploy_revision recipe' do
      chef_run.should include_recipe 'ingenerator-source::deploy_revision'
    end
  end

  context 'when node[project][deploy] is invalid' do
    let (:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set['project']['deploy']['type'] = 'something random'
      end.converge(described_recipe)
    end

    it 'should throw an exception' do
      expect { chef_run }.to raise_error
    end
  end

end
