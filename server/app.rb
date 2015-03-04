require 'sinatra'
require 'travis_dedup'
require 'travis_dedup/version'

# sinatra logs to stderr which is an IO
# but we don't want to store other peoples token
# heroku still logs them in the router level, looks like there is no way of silencing them
# https://discussion.heroku.com/t/filter-password-tokens-from-heroku-logs/1048
module NoTokenLogging
  def write(*args)
    args.first.sub!(/token=\S+/, "token=[FILTERED]")
    super
  end
end
IO.prepend NoTokenLogging

get "/" do
  "Welcome to travis-dedup version #{TravisDedup::VERSION}"
end

post "/github" do
  sleep((params["delay"] || 5).to_i) # wait for travis to see the newly pushed commit

  TravisDedup.verbose = true
  TravisDedup.pro = params["pro"]
  result = TravisDedup.dedup_message(params.fetch("repo"), params.fetch("token"))
  puts result
  result
end
