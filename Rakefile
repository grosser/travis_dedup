require "bundler/setup"
require "bundler/gem_tasks"
require "bump/tasks" unless ENV["RACK_ENV"] == "production" # herkou does a rake -P :/

def server(extra=nil)
  exec "rackup server/config.ru #{extra}"
end

def child_pids(pid)
  pipe = IO.popen("ps -ef | grep #{pid}")

  pipe.readlines.map do |line|
    parts = line.split(/\s+/)
    parts[2].to_i if parts[3] == pid.to_s and parts[2] != pipe.pid.to_s
  end.compact
end

desc "run tests"
task :spec do
  sh "rspec spec"
end

task :server do
  server
end

task :test_server do
  pid = fork { server ">/dev/null 2>&1" }
  begin
    sleep 5
    repo = "some-public-token/travis-cron-test"
    token = "mi0l8uQlX3U5EHbE0ym31g"
    result = `curl --silent -X POST '127.0.0.1:9292/github?repo=#{repo}&token=#{token}'`
    raise "Server failed: #{result}" unless result.include?("Builds canceled")
  ensure
    (child_pids(pid) + [pid]).each { |pid| Process.kill(:TERM, pid) }
  end
end

task default: [:spec, :test_server]
