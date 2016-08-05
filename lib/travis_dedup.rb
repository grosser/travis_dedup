require 'faraday'
require 'json'
require 'optparse'

module TravisDedup
  ACTIVE = %w[created started queued]

  class << self
    attr_accessor :pro, :verbose, :branches

    def cli(argv)
      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /, "")
          Stop all builds on the same PR when a new job starts.

          Usage:
              travis-dedup your_org/your_repo $TRAVIS_ACCESS_TOKEN --pro

          Options:
        BANNER
        opts.on("--pro", "travis pro") { self.pro = true }
        opts.on("--branches", "dedup builds on branches too") { self.branches = true }
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
      dedup_builds(repo, access_token).last
    end

    def dedup_message(repo, access_token)
      all, canceled = dedup_builds(repo, access_token)
      canceled = (canceled.any? ? canceled.map { |b| b.fetch("id") }.join(", ") : "None")
      "Found #{all.size} builds, canceled: #{canceled}"
    end

    def access_token(github_token)
      request(:post, "auth/github", {github_token: github_token}, 'User-Agent' => 'Travis/1.0').fetch("access_token")
    end

    private

    def dedup_builds(repo, access_token)
      builds = active_builds(repo, access_token)
      cancel = duplicate_builds(builds)
      cancel(cancel, access_token)
      return builds, cancel
    end

    def cancel(builds, access_token)
      builds.each { |build| request :post, "builds/#{build.fetch("id")}/cancel", {}, headers(access_token) }
    end

    def duplicate_builds(builds)
      seen = []
      builds.select do |build|
        pr = build.fetch "pull_request_number"
        branch = build.fetch "branch"

        next if !pr && !branches

        id = pr || branch
        if seen.include?(id)
          true
        else
          # don't cancel master branch
          seen << id if id != 'master'
          false
        end
      end
    end

    # see http://docs.travis-ci.com/api/#builds
    def active_builds(repo, access_token)
      response = request(:get, "repos/#{repo}/builds", {}, headers(access_token))
      builds = response.fetch("builds").select { |b| ACTIVE.include?(b.fetch("state")) }
      builds.each { |build| build["branch"] = response.fetch("commits").detect { |c| c["id"] == build["commit_id"] }.fetch("branch") }
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
        raise(
          Faraday::Error,
          "Communication with travis failed when trying to #{method} #{path}\n" \
          "Response: #{response.status} - #{response.body}"
        )
      end
    end
  end
end
