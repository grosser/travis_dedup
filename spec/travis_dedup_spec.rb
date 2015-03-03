require "spec_helper"

github_token = "d092043dbbca509c8e3" << "61f812ece42156ef8d5f9" # token of user: some-public-token obfuscated so github does not delete it
access_token = TravisDedup.access_token(github_token)

describe TravisDedup do
  it "does not blow up when dedupping" do
    TravisDedup.dedup("some-public-token/travis-cron-test", access_token).should == [] # nothing canceled
  end
end
