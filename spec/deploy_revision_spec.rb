require 'spec_helper'

describe 'ingenerator-source::deploy_revision' do
  let (:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['project']['deploy']['type']                 = :deploy
      node.set['project']['deploy']['source']               = '/source-repo'
      node.set['project']['deploy']['destination']          = '/var/www/destination'
      node.set['project']['deploy']['owner']                = 'foouser'
      node.set['project']['deploy']['group']                = 'foogroup'
      node.set['project']['deploy']['force']                = false
      node.set['project']['deploy']['revision']             = 'some-sha'
      node.set['project']['deploy']['allow_blocked_branch'] = true
    end.converge(described_recipe)
  end

  context "when the checkout has a PROD_RELEASE_BLOCKER file" do
    before (:each) do
      original_exists = File.method(:exists?)
      File.stub('exists?') { |path| original_exists.call(path) }
      File.stub('exists?').with('/source-repo/PROD_RELEASE_BLOCKER').and_return true
      Chef::Log.stub(:warn).and_return true
    end

    it "aborts the chef run if project.deploy.allow_blocked_branch is false" do
      chef_run.node.set['project']['deploy']['allow_blocked_branch'] = false
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
      chef_run.node.set['project']['deploy']['allow_blocked_branch'] = true
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
    chef_run.should delete_directory('/var/www/destination/shared/cached-copy')
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
    chef_run.node.set['project']['deploy']['force'] = true
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

  it "runs the configured post-deploy hooks"

  context 'by default' do
    let (:chef_run) do
      # the destination must be set by the default recipe or attributes
      ChefSpec::Runner.new do |node|
        node.set['project']['deploy']['destination'] = '/var/www/destination'
      end.converge(described_recipe)
    end

    it "sets the deployment source to /var/www/www-source" do
      chef_run.node['project']['deploy']['source'].should eq('/var/www/www-source')
    end

    it "sets the checkout owner to www-data" do
      chef_run.node['project']['deploy']['owner'].should eq('www-data')
    end

    it "sets the checkout group to www-data" do
      chef_run.node['project']['deploy']['group'].should eq('www-data')
    end

    it "does not force deploy" do
      chef_run.node['project']['deploy']['force'].should be_false
    end

    it "does not allow deployment of blocked branches" do
      chef_run.node['project']['deploy']['allow_blocked_branch'].should be_false
    end

  end

end
