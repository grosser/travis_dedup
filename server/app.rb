require 'sinatra'
require 'travis_dedup'
require 'travis_dedup/version'

# sinatra logs to stderr which is an IO
# but we don't want to store other peoples token
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
  TravisDedup.pro = params["pro"]
  TravisDedup.dedup_message(params.fetch("repo"), params.fetch("token"))
end
