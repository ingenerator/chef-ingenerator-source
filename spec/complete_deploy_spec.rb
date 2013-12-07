require 'spec_helper'

describe 'ingenerator-source::complete_deploy' do
  let (:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['project']['deploy']['release_path'] = '/var/dest/releases/abcdef'
    end.converge(described_recipe)
  end

  it "does nothing as standard" do
    chef_run
  end

  context 'when node[project][deploy][release_path] is not set' do
    let (:chef_run) { ChefSpec::Runner.new.converge described_recipe }

    it 'should throw an exception' do
      expect { chef_run }.to raise_error
    end
  end

end
