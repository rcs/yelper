# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "yelper/version"

Gem::Specification.new do |s|
  s.name        = "yelper"
  s.version     = Yelper::VERSION
  s.authors     = ["Ryan Sorensen"]
  s.email       = ["rcsorensen@gmail.com"]
  s.homepage    = "http://github.com/rcs/yelper"
  s.summary     = %q{Access Yelp's v2 API, with OAuth}
  s.description = %q{Exposes Yelp's v2 API, handling authentication and argument prettification for search calls}

  s.rubyforge_project = "yelper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "cucumber"
  s.add_development_dependency "aruba"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "awesome_print"
  if RUBY_PLATFORM.downcase.include?("darwin")
    s.add_development_dependency "guard"
    s.add_development_dependency "growl"
    s.add_development_dependency "rb-fsevent"
  end


  s.add_runtime_dependency "faraday_middleware", "~> 0.7"
  s.add_runtime_dependency "simple_oauth" # For faraday request oauth
  s.add_runtime_dependency "multi_json" # For faraday response multijson
  s.add_runtime_dependency "rash" # For faraday response rashie
  s.add_runtime_dependency "faraday", "~> 0.7"
end
