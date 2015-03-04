require 'sinatra'
require 'travis_dedup'

post "/github" do
  TravisDedup.pro = params["pro"]
  TravisDedup.dedup_message(params.fetch("repo"), params.fetch("token"))
end
