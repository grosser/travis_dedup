require "bundler/setup"
require "bundler/gem_tasks"
require "bump/tasks" unless ENV["RACK_ENV"] == "production" # herkou does a rake -P :/

def server(extra=nil)
  command = File.readlines("Procfile").first.strip.
    sub('web: ', '').
    sub('$PORT', '3000').
    sub('$RACK_ENV', 'development')
  exec "#{command} #{extra}"
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
    sleep 5 # wait for server to start

    # test the welcome page
    result = `curl --silent '127.0.0.1:3000'`
    raise "Server version failed: #{result}" unless result.include?("Welcome to travis-dedup")

    # test a dedup
    repo = "some-public-token/travis-cron-test"
    token = "mi0l8uQlX3U5EHbE0ym31g"
    result = `curl --silent -X POST '127.0.0.1:3000/github?repo=#{repo}&token=#{token}&delay=0'`
    raise "Server dedup failed: #{result}" unless result.include?("builds, canceled:")
  ensure
    (child_pids(pid) + [pid]).each { |pid| Process.kill(:TERM, pid) }
  end
end

task default: [:spec, :test_server]
