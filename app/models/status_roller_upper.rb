class StatusRollerUpper
  def initialize(payload)
    @payload = payload
  end

  def rollup
    Rails.logger.info("StatusRollerUpper#rollup for #{repo_user_name}/#{repo_name}:#{sha}")
    commit_status = CommitStatus.new(repo_user_name, repo_name, sha)
    Rails.logger.info(commit_status.other_tool_statuses.inspect)

    status_values = commit_status.other_tool_statuses.values.map { |status| status['state'] }.uniq
    return if status_values.empty?

    status_phrases = {
      'pending' => 'is pending',
      'error' => 'has errored',
      'failure' => 'failed',
      'success' => 'succeeded'
    }


    description = commit_status.other_tool_statuses.map { |tool, status| "#{tool} #{status_phrases[status['state']]}" }.join('. ')

    if status_values.include?('pending')
      mark('pending', description)
    elsif status_values.include?('error')
      mark('error', description)
    elsif status_values.include?('failure')
      mark('failure', description)
    elsif status_values.include?('success')
      mark('success', description)
    end
  end

  private

  def mark(state, description)
    Rails.logger.info("Going to mark #{sha} as #{state}: #{description}")
    target_url = "#{HOST}/statuses/#{repo_user_name}/#{repo_name}/#{sha}"

    github.repos.statuses.create(repo_user_name, repo_name, sha, {
    # GithubRepos.new(repo.user).set_status(repo_user_name, repo_name, sha, {
      state: state,
      target_url: target_url,
      description: description
    })
  end

  def repo_user_name
    @payload.repository.owner.login
  end

  def repo_name
    @payload.repository.name
  end

  def sha
    @payload.sha
  end

  def github
    @github ||= repo.user.github
  end

  def repo
    @repo ||= Repo.find_by_user_name_and_repo_name(repo_user_name, repo_name)
  end
end
