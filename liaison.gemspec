# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "liaison/version"

Gem::Specification.new do |s|
  s.name        = "liaison"
  s.version     = Liaison::VERSION
  s.authors     = ["Mike Burns"]
  s.email       = ["mike@mike-burns.com"]
  s.homepage    = "https://github.com/mike-burns/liaison"
  s.license     = 'BSD'
  s.summary     = %q{A Rails presenter class.}
  s.description = %q{An object that works with form_for that encapsulates validations and data management, leaving the business logic up to your testable old self.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('activemodel')

  s.add_development_dependency('rspec')
  s.add_development_dependency('rake')
end
