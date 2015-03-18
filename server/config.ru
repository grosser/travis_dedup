require File.expand_path('../app', __FILE__)

if token = ENV["ROLLBAR"]
  require 'rollbar'
  Rollbar.configure do |config|
    config.disable_monkey_patch = true
    config.access_token = token
    config.exception_level_filters = { 'Sinatra::NotFound' => 'ignore' }
  end

  require 'rollbar/middleware/sinatra'
  use Rollbar::Middleware::Sinatra
elsif ENV["RACK_ENV"] == "production" && !ENV["NO_ROLLBAR"]
  raise "Rollbar is not active! (disable by setting NO_ROLLBAR=1)"
end

run Sinatra::Application
