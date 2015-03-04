require 'faraday'
require 'json'
require 'optparse'

module TravisDedup
  PENDING = %w[created started queued]

  class << self
    attr_accessor :pro

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

      puts dedup_message(*argv, options)
      0
    end

    def dedup_message(repo, access_token)
      canceled = dedup(repo, access_token)
      canceled = (canceled.any? ? canceled.map { |b| b.fetch("id") }.join(", ") : "None")
      "Builds canceled: #{canceled}"
    end

    def dedup(repo, access_token)
      headers = {
        "Authorization" => %{token "#{access_token}"},
        'Accept' => 'application/vnd.travis-ci.2+json' # otherwise we only get half the build data
      }
      builds = request(:get, "repos/#{repo}/builds", {}, headers).fetch("builds")

      seen = []
      builds.select! { |b| PENDING.include?(b.fetch("state")) }
      builds.select do |build|
        pr = build.fetch("pull_request_number")
        id = build.fetch("id")
        if seen.include?(pr)
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
      case response.status
      when 200 then JSON.parse(response.body)
      when 204 then nil
      else
        raise response.inspect
      end
    end
  end
end
