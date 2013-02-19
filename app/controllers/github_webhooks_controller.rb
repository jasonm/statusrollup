class GithubWebhooksController < ApplicationController
  def repo_hook
    event = request.headers['X-GitHub-Event']

    Rails.logger.info(event.inspect)

    if event == 'status'
      payload = Hashie::Mash.new(JSON.parse(params[:payload]))
      StatusRollerUpper.new(payload).rollup
    end

    render text: "OK", status: 200
  end
end
