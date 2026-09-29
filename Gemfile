# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

group :development do
  gem 'cocoapods', '~> 1.12'
  gem 'fastlane'
end

group :development, :ci do
  gem 'jazzy'
  # mustache 1.1.3 breaks jazzy on Ruby 3.4 (Pathname passed to template_path=)
  gem 'mustache', '~> 1.1.1', '< 1.1.2'
  gem 'danger'
  gem 'danger-swiftlint'
  gem 'minitest'
end
