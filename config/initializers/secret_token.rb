# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
StatusRollup::Application.config.secret_token = if Rails.env.production?
  ENV['SECRET_TOKEN'] || raise("Set ENV['SECRET_TOKEN'] for production")
else
  'f46786bb3acbbca3ddb96e3a75bc2aa93718a3fec31d5c4b5545a29a82c52fdfafbe4ad0cd73bf88c7297a5fb2e961c1f4db731e0801fef2095dc5ac92289eb1'
end

