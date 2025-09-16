# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

group :development do
  gem 'cocoapods', '~> 1.12'
  gem 'fastlane'
  gem 'abbrev' # Error handling for ruby 3.4.0 and later https://github.com/fastlane/fastlane/issues/29183
end

group :development, :ci do
  gem 'jazzy'
  gem 'danger'
  gem 'danger-swiftlint'
  gem 'slather'
end

