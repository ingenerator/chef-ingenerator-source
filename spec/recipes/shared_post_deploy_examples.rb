shared_examples 'sets release path and triggers hooks' do
  let (:chef_run) { chef_runner.converge('test_helpers::test_noop', described_recipe) }

  %w(on_prepare on_complete).each do |hook_name|
    context "when a #{hook_name} hook is defined" do
      it 'sets the release path and runs the hook recipe' do
        chef_runner.node.normal['project']['deploy'][hook_name] = 'test_helpers::test_hook'
        expect(chef_run).to include_recipe('test_helpers::test_hook')
        expect(chef_run.node['test']['hook']['release_path']).to eq expect_path
      end
    end
  end
end
