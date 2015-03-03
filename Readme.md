Stop all builds on the same PR when a new job starts.

Generate an access token `curl -X POST "https://api.travis-ci.com/auth/github" -d "github_token=YOUR_GITHUB_TOKEN"`

Make your first build step

```Ruby
require 'travis_dedup'
TravisDedup.pro = true
TravisDedup.dedup('your_org/your_repo', 'YOUR_ACCESS_TOKEN')
```

optionally generate the token at runtime, but keeping the access token around is far less dangerous

```Ruby
access_token = TravisDedup.access_token(github_token)
```

Install
=======

```Bash
gem install travis_dedup
```

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT
