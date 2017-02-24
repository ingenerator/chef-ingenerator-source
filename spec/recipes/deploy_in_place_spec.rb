require 'spec_helper'

describe 'ingenerator-source::deploy_in_place' do
  let (:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.normal['project']['deploy']['type']        = :in_place
      node.normal['project']['deploy']['source']      = '/source-repo'
      node.normal['project']['deploy']['destination'] = '/var/www/destination'
      node.normal['project']['deploy']['owner']       = 'foouser'
      node.normal['project']['deploy']['group']       = 'foogroup'
    end.converge(described_recipe)
  end

  it "ensures the destination parent directory exists and is owned by the checkout owner" do
    expect(chef_run).to create_directory('/var/www/destination').with(
      user:      'foouser',
      group:     'foogroup',
      mode:      0755,
      recursive: true
    )
  end

  it "creates a symlink from source to destination/current owned by the checkout owner" do
    expect(chef_run).to create_link('/var/www/destination/current').with(
      user:   'foouser',
      group:  'foogroup'
    )
    link = chef_run.link('/var/www/destination/current')
	expect(link).to link_to('/source-repo')
  end

  it "sets the release path attribute on the node for use in recipes" do
    expect(chef_run.node['project']['deploy']['release_path']).to eq('/var/www/destination/current')
  end

  it "runs the configured on_prepare deploy hook recipe" do
    expect(chef_run).to include_recipe(chef_run.node['project']['deploy']['on_prepare'])
  end

  it "runs the configured on_complete deploy hook recipe" do
    expect(chef_run).to include_recipe(chef_run.node['project']['deploy']['on_complete'])
  end

  context 'by default' do
    let (:chef_run) do
      # the destination must be set by the default recipe or attributes
      ChefSpec::SoloRunner.new do |node|
        node.normal['project']['deploy']['destination'] = '/var/www/destination'
      end.converge(described_recipe)
    end

    it "sets the deployment source to /vagrant" do
      expect(chef_run.node['project']['deploy']['source']).to eq('/vagrant')
    end

    it "sets the checkout owner to www-data" do
      expect(chef_run.node['project']['deploy']['owner']).to eq('www-data')
    end

    it "sets the checkout group to www-data" do
      expect(chef_run.node['project']['deploy']['group']).to eq('www-data')
    end

  end

end
