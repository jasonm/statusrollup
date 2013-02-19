class StatusRollerUpper
  STATUS_DESCRIPTIONS = {
    'success' => 'StatusRollup loves this commit',
    'failure' => 'StatusRollup is sad about this commit'
  }

  def initialize(push)
    @push = push
  end

  def rollup
    Rails.logger.info("PushStatusChecker#check_and_update for push #{@push.user_name}/#{@push.repo_name}:#{@push.commits.map(&:id).join(',')}")

    @push.commits.each do |commit|
      check_commit(commit)
    end
  end

  private

  def check_commit(commit)
    mark(commit, 'success')

    # TODO: logic should fetch other commit statuses, demux by tool, and decide if succes/failure
    # if all_tools_passing?
    #   mark(commit, 'success')
    # else
    #   mark(commit, 'failure')
    # end
  end

  def mark(commit, state)
    target_url = "#{HOST}/agreements/#{@push.user_name}/#{@push.repo_name}"

    GithubRepos.new(repo_agreement.user).set_status(@push.user_name, @push.repo_name, sha = commit.id, {
      state: state,
      target_url: target_url,
      description: STATUS_DESCRIPTIONS[state]
    })
  end
end
