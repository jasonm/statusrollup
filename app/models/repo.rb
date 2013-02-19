class Repo < ActiveRecord::Base
  belongs_to :user

  validates :repo_name, presence: true
  validates :user_name, presence: true
  validate :only_once_per_repo

  attr_accessible :user_name, :repo_name

  def create_github_repo_hook
    hook_inputs = {
      'name' => 'web',
      'config' => {
        'url' => "#{HOST}/repo_hook"
      }
    }

    response = GithubRepos.new(self.user).create_hook(user_name, repo_name, hook_inputs)

    self.update_attribute(:github_repo_hook_id, response['id'])
  end

  def delete_github_repo_hook
    if github_repo_hook_id
      GithubRepos.new(self.user).delete_hook(user_name, repo_name, github_repo_hook_id)
      self.update_attribute(:github_repo_hook_id, nil)
    end
  end

  def owned_by?(candidate)
    candidate == self.user
  end

  private

  def only_once_per_repo
    existing = Repo.find_by_user_name_and_repo_name(user_name, repo_name)
    if existing && (existing != self)
      errors[:base] << "StatusRollup is already enabled for #{user_name}/#{repo_name}"
    end
  end
end
