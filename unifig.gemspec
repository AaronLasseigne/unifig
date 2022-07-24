# frozen_string_literal: true

require_relative 'lib/unifig/version'

Gem::Specification.new do |spec|
  spec.name = 'unifig'
  spec.version = Unifig::VERSION
  spec.license = 'MIT'

  spec.authors = ['Aaron Lasseigne']
  spec.email = ['aaron.lasseigne@gmail.com']

  spec.summary = 'A pluggable system for loading external variables from one or more providers (e.g. ENV).'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/AaronLasseigne/unifig'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.required_ruby_version = '>= 2.7.0'

  spec.files =
    %w[CHANGELOG.md CONTRIBUTING.md LICENSE.txt README.md] +
    Dir.glob(File.join('lib', '**', '*.rb'))
  spec.test_files = Dir.glob(File.join('spec', '**', '*.rb'))
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
end
