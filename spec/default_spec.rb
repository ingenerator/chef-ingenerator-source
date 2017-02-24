require 'spec_helper'

describe 'ingenerator-source::default' do
  let (:chef_run) { ChefSpec::SoloRunner.new.converge described_recipe }

  context 'by default' do
    it "uses the full deployment recipe" do
      expect(chef_run.node['project']['deploy']['type']).to be(:deploy)
    end

    it "sets the deploy destination to /var/www/{project_name}" do
      chef_run = ChefSpec::SoloRunner.new do |node|
        node.normal['project']['name'] = 'thisproject'
      end.converge(described_recipe)

      expect(chef_run.node['project']['deploy']['destination']).to eq('/var/www/thisproject')
    end

    it "sets the checkout owner to www-data" do
      expect(chef_run.node['project']['deploy']['owner']).to eq('www-data')
    end

    it "sets the checkout group to www-data" do
      expect(chef_run.node['project']['deploy']['group']).to eq('www-data')
    end

    it "attaches ingenerator-source::prepare_deploy as the on_prepare hook" do
      expect(chef_run.node['project']['deploy']['on_prepare']).to eq('ingenerator-source::prepare_deploy')
    end

    it "attaches ingenerator-source::complete_deploy as the on_prepare hook" do
      expect(chef_run.node['project']['deploy']['on_complete']).to eq('ingenerator-source::complete_deploy')
    end

  end

  context 'when node[project][deploy] is :in_place' do
    let (:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['project']['deploy']['type'] = :in_place
      end.converge(described_recipe)
    end

    it 'should run the deploy_in_place recipe' do
      expect(chef_run).to include_recipe 'ingenerator-source::deploy_in_place'
    end
  end

  context 'when node[project][deploy] is :deploy' do
    let (:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['project']['deploy']['type'] = :deploy
      end.converge(described_recipe)
    end

    it 'should run the deploy_revision recipe' do
      expect(chef_run).to include_recipe 'ingenerator-source::deploy_revision'
    end
  end

  context 'when node[project][deploy] is \'in_place\' from json' do
    let (:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['project']['deploy']['type'] = 'in_place'
      end.converge(described_recipe)
    end

    it 'should run the deploy_in_place recipe' do
      expect(chef_run).to include_recipe 'ingenerator-source::deploy_in_place'
    end
  end

  context 'when node[project][deploy] is \'deploy\' from json' do
    let (:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['project']['deploy']['type'] = 'deploy'
      end.converge(described_recipe)
    end

    it 'should run the deploy_revision recipe' do
      expect(chef_run).to include_recipe 'ingenerator-source::deploy_revision'
    end
  end

  context 'when node[project][deploy] is invalid' do
    let (:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['project']['deploy']['type'] = 'something random'
      end.converge(described_recipe)
    end

    it 'should throw an exception' do
      expect { chef_run }.to raise_error
    end
  end

end
