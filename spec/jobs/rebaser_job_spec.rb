require 'rails_helper'

RSpec.describe RebaserJob, type: :job do
  let(:user) { create(:user) }
  let(:repo) { create(:repo, user: user) }
  let(:rebase) { create(:rebase, repo: repo.name) }
  let(:admin_repo) { build(:admin_repo, permissions: double(admin: true)) }
  let(:git_repo) { build(:git_repo) }
  let(:collaborator) { double(id: 258) }
  let(:webhook) { build(:webhook) }
  let(:deploy_key) { build(:deploy_key) }
  let(:status) { { statuses: [{ context: 'ProjectR', state: 'pending' }] } }
  let(:pull) { { 'state' => 'open' } }
  let(:pull_request) { build(:pull_request) }
  let(:payload) do
    {
      'repository' => { 'full_name' => repo.name },
      'pull_request' => pull_request
    }
  end
  let(:github) do
    double(
      repos: [admin_repo],
      collaborators: [collaborator],
      repo: git_repo,
      hooks: [webhook],
      create_hook: webhook,
      deploy_keys: [deploy_key],
      add_deploy_key: deploy_key,
      create_status: status,
      status: status,
      pull: pull
    )
  end

  before do
    allow(RefresherJob).to receive(:new).and_return(double(perform: []))
    allow(Octokit::Client).to receive(:new).and_return(github)
  end

  context 'when work in progress' do
    let(:pull_request) { build(:pull_request, title: 'title #wip') }

    before do
      expect(described_class.perform_now(payload))
    end

    it { expect(Rebase.find_by(repo: repo.name).status).to eq('pending') }
  end

  context 'when conflict' do
    let(:status) { { statuses: [{ context: 'ProjectR', state: 'error' }] } }

    before do
      allow_any_instance_of(Github).to receive(:rebase).and_return('conflict')
      expect(described_class.perform_now(payload))
    end

    it { expect(Rebase.find_by(repo: repo.name).status).to eq('error') }
  end

  context 'when fail' do
    let(:status) { { statuses: [{ context: 'ProjectR', state: 'failure' }] } }

    before do
      allow_any_instance_of(Github).to receive(:rebase).and_return('fail')
      allow(PusherJob).to receive(:new).and_return(double(perform: []))
      expect(described_class.perform_now(payload))
    end

    it { expect(Rebase.find_by(repo: repo.name).status).to eq('failure') }
  end

  context 'when success' do
    let(:status) { { statuses: [{ context: 'ProjectR', state: 'success' }] } }

    before do
      allow_any_instance_of(Github).to receive(:rebase).and_return(nil)
      expect(described_class.perform_now(payload))
    end

    it { expect(Rebase.find_by(github_id: pull_request['id']).status).to eq('success') }
  end

  context 'when status not fined' do
    let(:status) { { statuses: [] } }

    before do
      allow_any_instance_of(Github).to receive(:rebase).and_return(nil)
      expect(described_class.perform_now(payload))
    end

    it { expect(Rebase.find_by(github_id: pull_request['id']).status).to eq('undefined') }
  end
end
