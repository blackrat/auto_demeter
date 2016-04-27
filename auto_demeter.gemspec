# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'auto_demeter/version'

Gem::Specification.new do |spec|
  spec.name = 'auto_demeter'
  spec.version = AutoDemeter::VERSION
  spec.authors = ['Paul McKibbin']
  spec.email = ['pmckibbin@gmail.com']
  spec.description = %q{Create automated methods for all children or parents to allow a request to be handled more easily than defining a long chain}
  spec.summary = %q{Automated demeter methods}
  spec.homepage = ''
  spec.license = 'MIT'

  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'sqlite3'

  if RUBY_VERSION >= '1.9'
    spec.add_development_dependency 'bundler'
    spec.add_development_dependency 'rake'
    spec.add_development_dependency 'active_record'
    spec.add_development_dependency 'simplecov'
  else
    spec.add_development_dependency 'bundler', '~> 1.3'
    spec.add_development_dependency 'rake', '~>0.9.2'
    spec.add_development_dependency 'activerecord'
    spec.add_development_dependency 'rcov'
  end
end
