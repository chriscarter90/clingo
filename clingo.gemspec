# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'clingo/version'

Gem::Specification.new do |spec|
  spec.name                      = "clingo"
  spec.version                   = Clingo::VERSION
  spec.authors                   = ["Chris Carter"]
  spec.email                     = ["chris.carter1@ntlworld.com"]
  spec.required_ruby_version     = ">= 2.3.0"

  spec.summary       = %q{Ruby wrapper for Clingo 4.X}
  spec.description   = %q{A ruby wrapper to integrate with Clingo 4.x}
  spec.homepage      = "https://github.com/chriscarter90/clingo"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "parslet", "~> 1.7"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.2"
end
