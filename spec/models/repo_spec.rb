require 'spec_helper'

describe Repo do
  it { should validate_presence_of :user_name }
  it { should validate_presence_of :repo_name }
  it { should belong_to :user }

  it { should allow_mass_assignment_of(:repo_name) }
  it { should allow_mass_assignment_of(:user_name) }
  it { should_not allow_mass_assignment_of(:user_id) }

  it "sets user_name" do
    user = build(:user, nickname: "jimbo")
    repo = build(:repo, user: user)

    repo.save

    expect(repo.user_name).to eq("jimbo")
    expect(repo.reload.user_name).to eq("jimbo")
  end

  it "create a github repo hook" do
    repo = build(:repo)

    hook_inputs = {
      'name' => 'web',
      'config' => {
        'url' => "#{HOST}/repo_hook"
      }
    }

    github_repos = double(create_hook: { 'id' => 12345 })
    GithubRepos.stub(new: github_repos)

    github_repos.should_receive(:create_hook).with(repo.user_name, repo.repo_name, hook_inputs)
    GithubRepos.should_receive(:new).with(repo.user)

    repo.create_github_repo_hook

    expect(repo.github_repo_hook_id).to eq(12345)
  end

  it "can delete its github repo hook" do
    repo = build(:repo, github_repo_hook_id: 7890)

    hook_inputs = {
      'name' => 'web',
      'config' => {
        'url' => "#{HOST}/repo_hook"
      }
    }

    github_repos = double(delete_hook: nil) # on not-found, raises Github::Error::NotFound
    GithubRepos.stub(new: github_repos)

    github_repos.should_receive(:delete_hook).with(repo.user_name, repo.repo_name, repo.github_repo_hook_id)
    GithubRepos.should_receive(:new).with(repo.user)

    repo.delete_github_repo_hook
    expect(repo.github_repo_hook_id).to be_nil
  end

  it "knows who owns it" do
    owner = build(:user)
    non_owner = build(:user)
    repo = build(:repo, user: owner)

    expect(repo.owned_by?(owner)).to be_true
    expect(repo.owned_by?(non_owner)).to be_false
  end

  it "validates uniqueness on user_name/repo_name" do
    user = create(:user, nickname: 'alice')
    first = create(:repo, user: user, repo_name: 'alpha')
    second = build(:repo, user: user, repo_name: 'alpha')

    expect(second).to_not be_valid
    expect(second.errors[:base]).to include("StatusRollup is already enabled for alice/alpha")

    expect(first).to be_valid
  end
end
