class ReposController < ApplicationController
  def new
    @repos = repos_for_current_user
    @repo = Repo.new
  end

  def create
    @repo = current_user.repos.new
    # binding.pry
    if params[:repo]
      @repo.user_name, @repo.repo_name = params[:repo][:user_name_repo_name].split('/')
    end

    if @repo.save
      @repo.create_github_repo_hook
      new_path = repo_path(user_name: @repo.user_name, repo_name: @repo.repo_name)
      message = "StatusRollup is enabled for #{@repo.user_name}/#{@repo.repo_name}."
      redirect_to new_path, notice: message
    else
      @repos = repos_for_current_user
      render 'new'
    end
  end

  def show
    @repo = Repo.find_by_user_name_and_repo_name!(params[:user_name], params[:repo_name])
  end

  private

  def repos_for_current_user
    DevModeCache.cache("repos-for-#{current_user.uid}") do
      GithubRepos.new(current_user).repos
    end
  end
end
