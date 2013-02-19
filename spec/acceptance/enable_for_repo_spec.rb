require 'spec_helper'

feature "Enabling StatusRollup on a repo" do
  let(:token) { 'abc123' }
  let(:resulting_github_repo_hook_id) { 2345 }

  background do
    mock_github_oauth(
      credentials: { token: token },
      info: { nickname: 'jasonm' }
    )

    mock_github_user_repos(
      oauth_token: token,
      repos: [
        { name: 'alpha', id: 123, owner: { login: 'jasonm' } },
        { name: 'beta',  id: 456, owner: { login: 'jasonm' } }
      ]
    )

    mock_github_repo_hook({
      user_name: 'jasonm',
      repo_name: 'beta',
      oauth_token: token,
      resulting_hook_id: resulting_github_repo_hook_id
    })

    mock_github_user_orgs(
      oauth_token: token,
      orgs: []
    )
  end

  scenario "for a public repo you own" do
    visit '/'
    click_link 'Sign in with GitHub to get started'
    page.should have_content('Welcome, jasonm!')
    page.should have_content("Choose a project")
    page.should have_content("jasonm/alpha")
    page.should have_content("jasonm/beta")

    select 'jasonm/beta', from: 'user-name-repo-name'
    click_button 'Enable StatusRollup'

    page.should have_content('StatusRollup is enabled for jasonm/beta')

    visit '/statuses/jasonm/beta'
    page.should have_content('StatusRollup is enabled for jasonm/beta')

    visit '/sign_out'
    visit '/statuses/jasonm/beta'
    page.should have_content('StatusRollup is enabled for jasonm/beta')
  end

  scenario "for a public repo in an organization you admin" do
    mock_github_user_orgs(
      oauth_token: token,
      orgs: [
        { login: 'my-adminned-org' },
        { login: 'someone-elses-org' }
      ]
    )

    mock_github_org_repos(
      oauth_token: token,
      org: 'my-adminned-org',
      repos: [
        { name: 'chi',   id: 333, owner: { login: 'my-adminned-org' }, permissions: { admin: true, push: true, pull: true } },
        { name: 'delta', id: 444, owner: { login: 'my-adminned-org' }, permissions: { admin: true, push: true, pull: true } }
      ]
    )

    mock_github_org_repos(
      oauth_token: token,
      org: 'someone-elses-org',
      repos: [
        { name: 'epsilon', id: 555, owner: { login: 'someone-elses-org' }, permissions: { admin: false, push: true, pull: true } }
      ]
    )

    mock_github_repo_hook({
      user_name: 'my-adminned-org',
      repo_name: 'chi',
      oauth_token: token,
      resulting_hook_id: resulting_github_repo_hook_id
    })

    visit '/'
    click_link 'Sign in with GitHub to get started'
    page.should have_content('Welcome, jasonm!')
    page.should have_content("Choose a project")
    page.should have_content("my-adminned-org/chi")
    page.should have_content("my-adminned-org/delta")
    page.should have_no_content("someone-elses-org/epsilon")

    select 'my-adminned-org/chi', from: 'user-name-repo-name'
    click_button 'Enable StatusRollup'

    inputs = {
      'name' => 'web',
      'events' => 'status',
      'config' => {
        'url' => "#{HOST}/repo_hook"
      }
    }

    a_request(:post, "https://api.github.com/repos/my-adminned-org/chi/hooks?access_token=#{token}").with(body: inputs.to_json).should have_been_made

    expect(Repo.last.github_repo_hook_id).to eq(resulting_github_repo_hook_id)
  end

  scenario "it signs up for commit notifications" do
    visit '/'
    click_link 'Sign in with GitHub to get started'

    select 'jasonm/beta', from: 'user-name-repo-name'
    click_button 'Enable StatusRollup'

    inputs = {
      'name' => 'web',
      'events' => 'status',
      'config' => {
        'url' => "#{HOST}/repo_hook"
      }
    }

    a_request(:post, "https://api.github.com/repos/jasonm/beta/hooks?access_token=#{token}").with(body: inputs.to_json).should have_been_made

    expect(Repo.last.github_repo_hook_id).to eq(resulting_github_repo_hook_id)
  end

  context "error handling" do
    scenario 'Require repo to be chosen' do
      visit '/'
      click_link 'Sign in with GitHub to get started'
      click_button 'Enable StatusRollup'
      page.should have_content("Repo name can't be blank")
    end

    scenario "only lets you enable once per repo" do
      visit '/'
      click_link 'Sign in with GitHub to get started'

      select 'jasonm/beta', from: 'user-name-repo-name'
      click_button 'Enable StatusRollup'

      visit '/repos/new'
      select 'jasonm/beta', from: 'user-name-repo-name'
      click_button 'Enable StatusRollup'

      page.should have_content("StatusRollup is already enabled for jasonm/beta")
    end
  end
end

feature "Failing GitHub OAuth" do
  scenario "It gracefully fails if you decline GitHub OAuth" do
    mock_github_oauth_failure
    visit '/'
    click_link 'Sign in with GitHub to get started'

    page.should have_content("You'll need to sign into GitHub.")
  end
end
