require "spec_helper"

github_token = "d092043dbbca509c8e3" << "61f812ece42156ef8d5f9" # token of user: some-public-token obfuscated so github does not delete it
access_token = TravisDedup.access_token(github_token)
repo = "some-public-token/travis-cron-test"

require 'webmock/rspec'

describe TravisDedup do
  it "does not blow up when dedupping" do
    WebMock.disable!
    TravisDedup.dedup(repo, access_token).should == [] # nothing canceled
  end

  it "can do a delete" do
    WebMock.enable!
    stub_request(:post, "https://api.travis-ci.org/foo/bar").
      to_return(:status => 204, :body => "", :headers => {})
    TravisDedup.send(:request, :post, "foo/bar", {}, {}).should == nil
  end

  describe ".cli" do
    def sh(command, options={})
      result = `#{command}`
      raise result if $?.success? == !!options[:fail]
      result
    end

    def dedup(command, options={})
      sh "#{Bundler.root}/bin/travis-dedup #{command}", options
    end

    def capture_stdout
      old, $stdout = $stdout, StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = old
    end

    it "shows version" do
      dedup("-v").should == "#{TravisDedup::VERSION}\n"
    end

    it "shows help" do
      dedup("-h").should include "Stop all builds on the same PR"
    end

    it "dedups" do
      dedup("#{repo} #{access_token}").should == "Found 0 builds, canceled: None\n"
    end

    it "shows help for strange arguments" do
      dedup("saasd", fail: true).should include "Stop all builds on the same PR"
    end

    it "shows canceled ids" do
      TravisDedup.should_receive(:request).exactly(2) # cancel call
      TravisDedup.should_receive(:active_builds).and_return([{"id" => 123}, {"id" => 456}, {"id" => 123}, {"id" => 456}])
      TravisDedup.should_receive(:duplicate_builds).and_return([{"id" => 123}, {"id" => 456}])
      out = capture_stdout do
        TravisDedup.cli(["a", "b"]).should == 0
      end
      out.should == "Found 4 builds, canceled: 123, 456\n"
    end

    it "does not dedup branches" do
      TravisDedup.send(:duplicate_builds, [
        {"state" => "x", "id" => 1, "pull_request_number" => nil},
        {"state" => "x", "id" => 1, "pull_request_number" => nil}
      ]).should == []
    end

    it "dedups PRs" do
      TravisDedup.send(:duplicate_builds, [
        {"state" => "x", "id" => 1, "pull_request_number" => "123"},
        {"state" => "x", "id" => 2, "pull_request_number" => "123"}
      ]).should == [{"state" => "x", "id" => 2, "pull_request_number" => "123"}]
    end

    it "sets pro" do
      begin
        TravisDedup.pro.should == nil
        TravisDedup.should_receive(:dedup_message).and_return("")
        capture_stdout do
          TravisDedup.cli(["a", "b", "--pro"]).should == 0
        end
        TravisDedup.pro.should == true
      ensure
        TravisDedup.pro = nil
      end
    end
  end
end
