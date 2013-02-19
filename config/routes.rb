StatusRollup::Application.routes.draw do
  root to: "pages#home", :as => :home
  match "/pages/*id" => 'pages#show', as: :page, format: false

  match 'auth/github/callback' => 'github_oauth#callback', :as => :github_oauth_callback
  match 'auth/failure' => 'github_oauth#failure'
  match 'sign_out' => 'sessions#destroy', :as => :sign_out

  resources :repos, only: [:new, :create]

  constraints :repo_name => /[^\/]+/ do
    get 'status/:user_name/:repo_name' => 'repos#show', :as => :repo
    get 'status/:user_name/:repo_name/:sha' => 'statuses#show', :as => :status
  end

  post 'repo_hook' => 'github_webhooks#repo_hook'
end
