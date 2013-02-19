require 'spec_helper'

describe 'receiving github repo webhook callbacks' do
  let(:token) { 'abc123' }

  before do
    mock_github_oauth(credentials: { token: token })
    mock_github_set_commit_status({ oauth_token: token, user_name: 'jasonm', repo_name: 'mangostickyrice', sha: 'aaa111' })
    mock_github_set_commit_status({ oauth_token: token, user_name: 'jasonm', repo_name: 'mangostickyrice', sha: 'bbb222' })
  end

  it 'gets a non-push event, responds with 200 OK' do
    post '/repo_hook', '{}', 'HTTP_X_GITHUB_EVENT' => 'slamalamadingdong'
    expect(response.code).to eq("200")
    expect(response.body).to eq("OK")
  end

  it 'gets a push to a repo without a locally-recorded repo, responds with 200 OK' do
    payload = { repository: { name: 'no-cla-here', owner: { name: 'wyattearp', email: 'codeslinger@gmail.com' } } }
    post '/repo_hook', { payload: payload.to_json }, 'HTTP_X_GITHUB_EVENT' => 'push'
    expect(response.code).to eq("200")
    expect(response.body).to eq("OK")
  end
end
