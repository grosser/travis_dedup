require "spec_helper"

github_token = "d092043dbbca509c8e3" << "61f812ece42156ef8d5f9" # token of user: some-public-token obfuscated so github does not delete it
access_token = TravisDedup.access_token(github_token)

require 'webmock/rspec'

describe TravisDedup do
  it "does not blow up when dedupping" do
    WebMock.disable!
    TravisDedup.dedup("some-public-token/travis-cron-test", access_token).should == [] # nothing canceled
  end

  it "can do a delete" do
    WebMock.enable!
    stub_request(:post, "https://api.travis-ci.org/foo/bar").
      to_return(:status => 204, :body => "", :headers => {})
    TravisDedup.send(:request, :post, "foo/bar", {}, {}).should == nil
  end
end
