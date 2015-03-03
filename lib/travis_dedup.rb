require 'faraday'
require 'json'

module TravisDedup
  class << self
    attr_accessor :pro

    def dedup(repo, access_token)
      headers = {
        "Authorization" => %{token "#{access_token}"},
        'Accept' => 'application/vnd.travis-ci.2+json' # otherwise we only get half the build data
      }
      builds = request(:get, "repos/#{repo}/builds", {}, headers).fetch("builds")

      seen = []
      builds.select! { |b| ["started", "create"].include?(b.fetch("state")) }
      builds.select do |build|
        pr = build.fetch("pull_request_number")
        id = build.fetch("id")
        if seen.include?(pr)
          puts "Canceling build #{id}"
          request :post, "builds/#{id}/cancel", {}, headers
          true
        else
          seen << pr
          false
        end
      end
    end

    def access_token(github_token)
      request(:post, "auth/github", github_token: github_token).fetch("access_token")
    end

    private

    def host
      pro ? "https://api.travis-ci.com" : "https://api.travis-ci.org"
    end

    def request(method, path, params, headers={})
      response = Faraday.send(method, "#{host}/#{path}", params, headers)
      raise response.inspect unless [200, 204].include?(response.status)
      JSON.parse(response.body)
    end
  end
end
