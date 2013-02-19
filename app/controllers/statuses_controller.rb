class StatusesController < ApplicationController
  def show
    @commit_status = CommitStatus.new(user_name, repo_name, sha)
    @github_commit_url = "https://github.com/#{user_name}/#{repo_name}/commit/#{sha}" 
  end

  private

  def user_name
    params[:user_name]
  end
  helper_method :user_name

  def repo_name
    params[:repo_name]
  end
  helper_method :repo_name

  def sha
    params[:sha]
  end
  helper_method :sha
end
