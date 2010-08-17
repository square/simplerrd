# encoding: utf-8

require 'bundler'

Gem::Specification.new do |s|
  s.name = "simplerrd"
  s.version = File.read("VERSION").strip

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = "1.3.7"

  s.authors = ["Sam Quigley", "Damon McCormick", "Matthew O'Connor"]
  s.email = "quigley@emerose.com"

  s.date = "2010-08-17"
  s.description = "SimpleRRD provides a simple Ruby interface for creating graphs with RRD"
  s.summary = "SimpleRRD provides a simple Ruby interface for creating graphs with RRD"
  s.homepage = "http://github.com/emerose/simplerrd"

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]

  s.require_paths = ["lib"]
  s.files = Dir['{lib,spec,examples}/**/*'] + %w(simplerrd.gemspec VERSION Rakefile README.markdown LICENSE Gemfile Gemfile.lock)
  s.test_files = Dir['spec/**/*']

  s.add_bundler_dependencies
end