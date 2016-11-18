[![Logo](https://raw.githubusercontent.com/grosser/travis_dedup/master/dedup.png)](https://github.com/grosser/travis_dedup)

*DEPRECATED* Travis will ship this as a feature in Q12017, currently in beta if you ask them.

Stop all builds on the same PR when a new job starts.

# Setup alternatives
 - A: using travis-dedup.herokuapp.com with github hooks
 - B: self hosting with github hooks
 - C: directly via .travis.yml


## A: Using travis-dedup.herokuapp.com via github push notification

Pro: simple / fast<br/>
Con: your travis token is sent via the web to a hosted service

 - Go to [Github settings](https://github.com/settings/tokens)
 - Click `Generate new token`, use name `Travis Dedup` with scopes `repo (all)` and `user (all)`
 - Generate an access token `curl -X POST "https://api.travis-ci.com/auth/github" -d "github_token=YOUR_GITHUB_TOKEN"`
 - setup github webhook hook to `https://travis-dedup.herokuapp.com/github?repo=your_org/your_repo&token=YOUR_ACCESS_TOKEN`
 - add `&pro=true` if you are using travis.com / private travis
 - add `&branches=true` if you also want to dedup builds on branches (like `master` or others)
The hook sleeps for 5s before inspecting the builds so the newly pushed build are found too.


## B: Self hosting on heroku
Pro: travis token is never sent over the web<br/>
Con: more complicated

 - If `TRAVIS_ACCESS_TOKEN` is set, token parameter is no longer required
 - [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)
 - See `A`, but use your own heroku subdomain

## C: directly via .travis.yml
Pro: no webservice required / token stays on travis<br/>
Con: slow to install gem / complicated with multiple envs

 - encrypt token `travis encrypt TRAVIS_ACCESS_TOKEN=YOUR_ACCESS_TOKEN`
 - add it to your `.travis.yml`
 - Make your first build step:

```Ruby
before_install: gem install travis_dedup && travis-dedup your_org/your_repo $TRAVIS_ACCESS_TOKEN --pro
```
#### With multiple envs in matrix
 - use `global: + matrix:`
 - use something like `matrix: GROUP=misc` + `before_install: "([ $GROUP = 'misc' ] && gem i travis_dedup && travis-dedup ... ) || [ $GROUP != 'misc' ]"`

optionally generate the token at runtime via curl, but keeping the access token around is far less dangerous

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/grosser/travis_dedup.png)](https://travis-ci.org/grosser/travis_dedup)
