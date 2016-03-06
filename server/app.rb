require 'sinatra'
require 'travis_dedup'
require 'travis_dedup/version'

class ProdLog
  def self.write(string)
    # sinatra logs to stderr which is an IO
    # but we don't want to store other peoples token
    # heroku still logs them in the router level, looks like there is no way of silencing them
    # https://discussion.heroku.com/t/filter-password-tokens-from-heroku-logs/1048
    string = string.sub(/token=\S+/, "token=[FILTERED]")

    # we run thin in multiple threads, so we need the thread id to make sense of the logs
    string = "TID:#{Thread.current.object_id.to_s[-7..-1]} #{string}"

    $stderr.write(string << "\n")
  end
end

LAST_CALLS = {}

def rate_limit(key, interval)
  now = Time.now.to_i
  if !LAST_CALLS[key] || LAST_CALLS[key] < (now - interval)
    LAST_CALLS[key] = now
    false
  else
    true
  end
end

configure do
  disable :logging
  use Rack::CommonLogger, ProdLog
end

get "/" do
  "Welcome to travis-dedup version #{TravisDedup::VERSION}"
end

post "/github" do
  repo = params["repo"] || halt(400, "Missing parameter repo")

  result = if rate_limit(repo, 5)
    "Too many requests"
  else
    ProdLog.write "STARTED #{repo}"

    sleep((params["delay"] || 5).to_i) # wait for travis to see the newly pushed commit

    token = params["token"] ||
      ENV['TRAVIS_ACCESS_TOKEN'] ||
      halt(400, "Missing parameter token")

    TravisDedup.pro = params["pro"]
    TravisDedup.branches = params["branches"]
    TravisDedup.dedup_message(repo, token)
  end
  ProdLog.write result
  result
end
