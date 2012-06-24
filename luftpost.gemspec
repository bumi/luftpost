# -*- encoding: utf-8 -*-
require File.expand_path('../lib/luftpost/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Michael Bumann"]
  gem.email         = ["michael@railslove.com"]
  gem.description   = %q{Gem handling mailgun incoming emails}
  gem.summary       = %q{Gem handling mailgun incoming emails}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "luftpost"
  gem.require_paths = ["lib"]
  gem.version       = Luftpost::VERSION
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'webmock'
  gem.add_dependency 'hashr', '~> 0.0.21'
  gem.add_dependency 'json'
end
