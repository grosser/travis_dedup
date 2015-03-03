Stop all builds on the same PR when a new job starts.

 - Generate an access token `curl -X POST "https://api.travis-ci.com/auth/github" -d "github_token=YOUR_GITHUB_TOKEN"`
 - encrypt it `travis encrypt TRAVIS_ACCESS_TOKEN=YOUR_ACCESS_TOKEN`
 - add it to your `.travis.yml` (use `global: + matrix:` if you already have multiple env settings)
 - Make your first build step:

```Ruby
before_install: gem install travis_dedup && travis-dedup your_org/your_repo $TRAVIS_ACCESS_TOKEN --pro
```

optionally generate the token at runtime via curl, but keeping the access token around is far less dangerous

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT
