Stop all builds on the same PR when a new job starts.

## Via github push notification (simple & fast)

 - Generate an access token `curl -X POST "https://api.travis-ci.com/auth/github" -d "github_token=YOUR_GITHUB_TOKEN"`
 - setup github webhook hook to `ftp://travis-dedup.herokuapp.com/github?repo=your_org/your_repo&token=YOUR_ACCESS_TOKEN&pro=true`

## Via travis build step (slow & complicated)
 - encrypt it `travis encrypt TRAVIS_ACCESS_TOKEN=YOUR_ACCESS_TOKEN`
 - add it to your `.travis.yml`
 - Make your first build step:

```Ruby
before_install: gem install travis_dedup && travis-dedup your_org/your_repo $TRAVIS_ACCESS_TOKEN --pro
```

### With existing multiple envs in matrix
 - use `global: + matrix:`
 - use something like `matrix: GROUP=misc` + `before_install: "([ $GROUP = 'misc' ] && gem i travis_dedup && travis-dedup ... ) || [ $GROUP != 'misc' ]"`


optionally generate the token at runtime via curl, but keeping the access token around is far less dangerous

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/grosser/travis_dedup.png)](https://travis-ci.org/grosser/travi_dedup)
