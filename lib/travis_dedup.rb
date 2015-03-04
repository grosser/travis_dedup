require 'faraday'
require 'json'
require 'optparse'

module TravisDedup
  PENDING = %w[created started queued]

  class << self
    attr_accessor :pro, :verbose

    def cli(argv)
      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /, "")
          Stop all builds on the same PR when a new job starts.

          Usage:
              travis-dedup your_org/your_repo $TRAVIS_ACCESS_TOKEN --pro

          Options:
        BANNER
        opts.on("--pro", "travis pro") { self.pro = true }
        opts.on("-h", "--help","Show this") { puts opts; exit }
        opts.on('-v', '--version','Show Version'){ require 'travis_dedup/version'; puts TravisDedup::VERSION; exit}
      end
      parser.parse!(argv)

      unless argv.size == 2
        puts parser
        return 1
      end

      puts dedup_message(*argv)
      0
    end

    def dedup(repo, access_token)
      builds = builds(repo, access_token)
      dedup_builds(builds, access_token)
    end

    def dedup_message(repo, access_token)
      builds = builds(repo, access_token)
      canceled = dedup_builds(builds, access_token)
      canceled = (canceled.any? ? canceled.map { |b| b.fetch("id") }.join(", ") : "None")
      "Found #{builds.size} builds, canceled: #{canceled}"
    end

    def access_token(github_token)
      request(:post, "auth/github", github_token: github_token).fetch("access_token")
    end

    private

    def dedup_builds(builds, access_token)
      seen = []
      builds.select! { |b| PENDING.include?(b.fetch("state")) }
      builds.select do |build|
        pr = build.fetch("pull_request_number")
        id = build.fetch("id")
        if seen.include?(pr)
          request :post, "builds/#{id}/cancel", {}, headers(access_token)
          true
        else
          seen << pr
          false
        end
      end
    end

    def builds(repo, access_token)
      request(:get, "repos/#{repo}/builds", {}, headers(access_token)).fetch("builds")
    end

    def headers(access_token)
      {
        "Authorization" => %{token "#{access_token}"},
        'Accept' => 'application/vnd.travis-ci.2+json' # otherwise we only get half the build data
      }
    end

    def host
      pro ? "https://api.travis-ci.com" : "https://api.travis-ci.org"
    end

    def request(method, path, params, headers={})
      response = Faraday.send(method, "#{host}/#{path}", params, headers)
      case response.status
      when 200 then JSON.parse(response.body)
      when 204 then nil
      else
        raise response.inspect
      end
    end
  end
end
