require 'spec_helper'

describe 'ingenerator-source::prepare_deploy' do
  let (:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.normal['project']['deploy']['release_path'] = '/var/dest/releases/abcdef'
    end.converge(described_recipe)
  end

  before(:each) do
    allow(File).to receive(:exists?).with(anything).and_call_original
  end

  context 'when the project has a composer.json in root' do
	before (:each) do
    allow(File).to receive(:exists?).with('/var/dest/releases/abcdef/composer.json').and_return true
	end

	it "installs the composer dependencies" do
	  chef_run.should install_composer_project('/var/dest/releases/abcdef')
	end

	it "installs dev dependencies if install_dev_tools is set" do
	  chef_run.node.normal['project']['install_dev_tools'] = true
	  chef_run.converge(described_recipe)
	  chef_run.should install_composer_project('/var/dest/releases/abcdef').with(
	    dev: true
	  )
	end

	it "does not install dev dependencies without install_dev_tools" do
	  chef_run.node.normal['project']['install_dev_tools'] = false
      chef_run.converge(described_recipe)
      chef_run.should install_composer_project('/var/dest/releases/abcdef').with(
        dev: false
      )
	end

	it "runs composer as the deploy user" do
	  chef_run.node.normal['project']['deploy']['owner'] = 'someuser'
      chef_run.converge(described_recipe)
      chef_run.should install_composer_project('/var/dest/releases/abcdef').with(
        run_as: 'someuser'
      )
	end

	it "runs composer in verbose mode so errors are visible" do
      chef_run.should install_composer_project('/var/dest/releases/abcdef').with(
        quiet: false
      )
    end
  end

  context 'without a composer.json' do
  	before (:each) do
      allow(File).to receive(:exists?).with('/var/dest/releases/abcdef/composer.json').and_return false
  	end

  	it "does not install composer dependencies" do
  	  chef_run.should_not install_composer_project('/var/dest/releases/abcdef')
  	end

  end

  context 'when node[project][deploy][release_path] is not set' do
    let (:chef_run) { ChefSpec::SoloRunner.new.converge described_recipe }

    it 'should throw an exception' do
      expect { chef_run }.to raise_error RuntimeError, /node.project.deploy.release_path/
    end
  end

end
