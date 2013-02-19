class CommitStatus
  attr_reader :user_name, :repo_name, :sha, :repo, :github

  def initialize(user_name, repo_name, sha)
    @user_name, @repo_name, @sha = user_name, repo_name, sha
    @repo = Repo.find_by_user_name_and_repo_name(user_name, repo_name)
    @github = repo.user.github
  end

  def commit_message
    commit_payload['commit']['message']
  end

  def commit_author
    name = commit_payload['commit']['author']['name']
    email = commit_payload['commit']['author']['email']
    "#{name} (#{email})"
  end

  def commit_author_gravatar_url
    commit_payload['author']['avatar_url']
  end

  def other_tool_statuses
    tool_status_pairings = other_tools.map { |tool| [tool, most_recent_status_for(tool)] }.flatten
    Hash[*tool_status_pairings]
  end

  def most_recent_status_for(tool)
    status_payload.
      select  { |status_hash| tool == tool_for_status_hash(status_hash) }.
      sort_by { |status_hash| Time.parse(status_hash['created_at']) }.
      last
  end

  def historical_statuses_for(tool)
    status_payload.
      select  { |status_hash| tool == tool_for_status_hash(status_hash) }.
      sort_by { |status_hash| Time.parse(status_hash['created_at']) }.
      reverse
  end

  def other_tools
    status_payload.
      map { |status_hash| tool_for_status_hash(status_hash) }.
      reject { |tool| tool == tool_for_this_very_app_yes_this_one }.
      uniq
  end

  private

  def tool_for_status_hash(status_hash)
    target_url = status_hash['target_url']
    host_for_target_url_is_good_enough = URI.parse(target_url).host rescue 'Unknown tool'
  end

  def tool_for_this_very_app_yes_this_one
    again_comma_the_host_is_good_enough_for_now = URI.parse(HOST).host
  end

  def status_payload
    @status_payload ||= github.repos.statuses.list(user_name, repo_name, sha)
  end

  def commit_payload
    @commit_payload ||= github.repos.commits.find(user_name, repo_name, sha)
  end
end
