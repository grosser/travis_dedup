name = "travis_dedup"
require "./lib/#{name}/version"

Gem::Specification.new name, TravisDedup::VERSION do |s|
  s.summary = "Stop all builds on the same PR when a new job starts."
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/#{name}"
  s.files = `git ls-files lib MIT-LICENSE.txt`.split("\n")
  s.license = "MIT"
  s.required_ruby_version = '>= 1.9.3'
  s.add_runtime_dependency "faraday"
  s.add_runtime_dependency "json"
end



