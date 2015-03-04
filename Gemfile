source "https://rubygems.org"

ruby File.read('.ruby-version').strip if ENV["RACK_ENV"] == "production" # strict ruby version only on heroku

gemspec

group :test do
  gem "rake"
  gem "rspec"
  gem "bump"
  gem "webmock"
end

# server
gem "sinatra"
gem "thin"
