FactoryGirl.define do
  factory :repo do
    association :user
    sequence(:repo_name) { |n| "repo_name#{n}" }
    user_name { user.nickname }
  end
end
