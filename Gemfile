source "https://rubygems.org"

ruby File.read('.ruby-version').strip

gemspec

group :test do
  gem "rake"
  gem "rspec"
  gem "bump"
  gem "webmock"
  gem "rack-test"
end

# server
gem "sinatra"
gem "thin"
gem "rollbar"
