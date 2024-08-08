# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "base64", "~> 0.2.0"
gem "rake", "~> 13.0", require: false

group :development do
  gem "rubocop", "~> 1.25", require: false
  gem "rubocop-rake", "~> 0.6.0", require: false
  gem "rubocop-rspec", "~> 2.9", require: false
end

group :test do
  gem "async-rspec", "~> 1.17", require: false
  gem "rspec", "~> 3.12", require: false
end

group :docs, optional: true do
  gem "yard", "~> 0.9.26", require: false
end

gem "syntax_tree", "~> 2.8", require: false
gem "syntax_tree-rbs", "~> 0.5.0", require: false
