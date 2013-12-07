require 'spec_helper'

describe 'ingenerator-source::deploy_in_place' do
  let (:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['project']['deploy']['type']        = :in_place
      node.set['project']['deploy']['source']      = '/source-repo'
      node.set['project']['deploy']['destination'] = '/var/www/destination'
      node.set['project']['deploy']['owner']       = 'foouser'
      node.set['project']['deploy']['group']       = 'foogroup'
    end.converge(described_recipe)
  end

  it "ensures the destination parent directory exists and is owned by the checkout owner" do
    chef_run.should create_directory('/var/www').with(
      user:      'foouser',
      group:     'foogroup',
      mode:      0755,
      recursive: true
    )
  end

  it "creates a symlink from source to destination owned by the checkout owner" do
    chef_run.should create_link('/var/www/destination').with(
      user:   'foouser',
      group:  'foogroup'
    )
    link = chef_run.link('/var/www/destination')
	link.should link_to('/source-repo')
  end

  it "runs the configured post-deploy hooks"

  context 'by default' do
    let (:chef_run) do
      # the destination must be set by the default recipe or attributes
      ChefSpec::Runner.new do |node|
        node.set['project']['deploy']['destination'] = '/var/www/destination'
      end.converge(described_recipe)
    end

    it "sets the deployment source to /vagrant" do
      chef_run.node['project']['deploy']['source'].should eq('/vagrant')
    end

    it "sets the checkout owner to www-data" do
      chef_run.node['project']['deploy']['owner'].should eq('www-data')
    end

    it "sets the checkout group to www-data" do
      chef_run.node['project']['deploy']['group'].should eq('www-data')
    end

  end

end
