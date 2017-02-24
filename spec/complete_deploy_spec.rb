require 'spec_helper'

describe 'ingenerator-source::complete_deploy' do
  let (:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.normal['project']['deploy']['release_path'] = '/var/dest/releases/abcdef'
    end.converge(described_recipe)
  end

  it "does nothing as standard" do
    expect(chef_run.resource_collection).to be_empty
  end

  context 'when node[project][deploy][release_path] is not set' do
    let (:chef_run) { ChefSpec::SoloRunner.new.converge described_recipe }

    it 'should throw an exception' do
      expect { chef_run }.to raise_error RuntimeError, /node.project.deploy.release_path/
    end
  end

end
