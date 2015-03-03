require "spec_helper"

github_token = "3fc14ddf4354c73a8b963d25d13fcde879787c82" # token of user: some-public-token
access_token = TravisDedup.access_token(github_token)

describe TravisDedup do
  it "does not blow up when dedupping" do
    TravisDedup.dedup("some-public-token/travis-cron-test", access_token).should == [] # nothing canceled
  end
end
