require 'spec_helper'

describe 'ingenerator-source::deploy_revision' do
  let (:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.normal['project']['deploy']['type']                 = :deploy
      node.normal['project']['deploy']['source']               = '/source-repo'
      node.normal['project']['deploy']['destination']          = '/var/www/destination'
      node.normal['project']['deploy']['owner']                = 'foouser'
      node.normal['project']['deploy']['group']                = 'foogroup'
      node.normal['project']['deploy']['force']                = false
      node.normal['project']['deploy']['revision']             = 'some-sha'
      node.normal['project']['deploy']['allow_blocked_branch'] = true
    end.converge(described_recipe)
  end

  before(:each) do
    allow(File).to receive(:exists?).with(anything).and_call_original
  end

  context "when the checkout has a PROD_RELEASE_BLOCKER file" do
    before (:each) do
      allow(File).to receive(:exists?).with('/source-repo/PROD_RELEASE_BLOCKER').and_return true
      Chef::Log.stub(:warn).and_return true
    end

    it "aborts the chef run if project.deploy.allow_blocked_branch is false" do
      chef_run.node.normal['project']['deploy']['allow_blocked_branch'] = false
      expect { chef_run.converge(described_recipe) }.to raise_error(RuntimeError)
    end

    it "logs a warning if project.deploy.allow_blocked_branch is true" do
      # have to accept at least once as chefspec converges this run twice
      expect(Chef::Log).to receive(:warn).at_least(:once).with(
        'You are deploying a blocked branch - check the PROD_RELEASE_BLOCKER'
      )
      chef_run.converge(described_recipe)
    end

    it "continues if project.deploy.allow_blocked_branch is true" do
      chef_run.node.normal['project']['deploy']['allow_blocked_branch'] = true
      chef_run.converge(described_recipe)
      chef_run.should deploy_deploy('/var/www/destination')
    end
  end

  it "ensures the required shared and releases directories exist and are correctly owned" do
    chef_run.should create_directory('/var/www/destination/shared').with(
      user:      'foouser',
      group:     'foogroup',
      mode:      0755,
      recursive: true
    )
    chef_run.should create_directory('/var/www/destination/releases').with(
      user:      'foouser',
      group:     'foogroup',
      mode:      0755,
      recursive: true
    )
  end

  it "removes the local cached-copy repository to prevent hardlink problems" do
    # The chef deployment recipe has problems with branch and commit references when new commits
    # are pulled from upstream
    chef_run.should delete_directory('/var/www/destination/shared/cached-copy').with(
      recursive: true
    )
  end


  it "deploys the revision from the source to the destination owned by the right user and group" do
    chef_run.should deploy_deploy('/var/www/destination').with(
      repo:     '/source-repo',
      revision: 'some-sha',
      user:     'foouser',
      group:    'foogroup'
    )
  end

  it "forces the deployment to re-rerun if required" do
    chef_run.node.normal['project']['deploy']['force'] = true
    chef_run.converge(described_recipe)
    chef_run.should force_deploy_deploy('/var/www/destination')
  end

  it "clears the rails-related deploy options" do
    chef_run.should deploy_deploy('/var/www/destination').with(
      symlink_before_migrate:     {},
      symlinks:                   {},
      create_dirs_before_symlink: [],
      purge_before_symlink:       []
    )
  end

  context "when the deploy runs" do
    # I know this is unpleasant, but I can't work out how to call the blocks with the correct state and scope
    # to mock it.
    before (:each) do
      `rm -rf /tmp/dest /tmp/src`
      `mkdir -p /tmp/dest/shared /tmp/dest/releases /tmp/src`
      `cd /tmp/src && git init && git config user.email "tmp@example.com" && git config user.name "test user" && git commit --allow-empty -m"initial-commit"`
      `sudo chmod -R 0777 /var/chef`
    end

    let (:known_sha) { `cd /tmp/src && git rev-parse HEAD`.chomp("\n") }

    let (:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['deploy']) do |node|
        node.normal['project']['deploy']['type']                 = :deploy
        node.normal['project']['deploy']['source']               = '/tmp/src'
        node.normal['project']['deploy']['destination']          = '/tmp/dest'
        node.normal['project']['deploy']['revision']             = 'HEAD'
        node.normal['project']['deploy']['force']                = true
        node.normal['project']['deploy']['allow_blocked_branch'] = true
        node.normal['project']['deploy']['owner']                 = ENV['USER']
        node.normal['project']['deploy']['group']                 = `id -ng`.chomp("\n")
      end.converge(described_recipe)
    end

    it "deploys to a directory named for the git sha and sets the release path attribute" do
      expect_path = '/tmp/dest/releases/'+known_sha
      chef_run.node['project']['deploy']['release_path'].should eq(expect_path)
      File.symlink?('/tmp/dest/current').should be true
      File.readlink('/tmp/dest/current').should eq(expect_path)
    end

    it "runs the configured on_prepare deploy hook recipe" do
      chef_run.should include_recipe(chef_run.node['project']['deploy']['on_prepare'])
    end

    it "runs the configured on_complete deploy hook recipe" do
      chef_run.should include_recipe(chef_run.node['project']['deploy']['on_complete'])
    end
  end

  context 'by default' do
    let (:chef_run) do
      # the destination must be set by the default recipe or attributes
      ChefSpec::SoloRunner.new do |node|
        node.normal['project']['deploy']['destination'] = '/var/www/destination'
      end.converge(described_recipe)
    end

    it "sets the deployment source to /var/www/www-source" do
      chef_run.node['project']['deploy']['source'].should eq('/var/www/www-source')
    end

    it "does not force deploy" do
      chef_run.node['project']['deploy']['force'].should be false
    end

    it "does not allow deployment of blocked branches" do
      chef_run.node['project']['deploy']['allow_blocked_branch'].should be false
    end
  end

end
