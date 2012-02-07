require File.dirname(__FILE__) + "/lib/newman/version"

Gem::Specification.new do |s|
  s.name = "newman"
  s.version = Newman::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.authors = ["Gregory Brown"]
  s.email = ["gregory.t.brown@gmail.com"]
  s.homepage = "http://github.com/mendicant-university/newman"
  s.summary = "A microframework for mail-centric applications"
  s.description = "A microframework for mail-centric applications"
  s.files = Dir.glob("{lib,examples}/**/*") + %w[README.md]
  s.require_path = 'lib'
  s.add_runtime_dependency 'mail', "~> 2.3.0"
  s.add_runtime_dependency 'tilt', "~> 1.3.3"

  s.add_development_dependency 'minitest', "~> 2.11.1"
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'purdytest'
  s.add_development_dependency 'rocco'
  s.add_development_dependency 'rake'

  s.required_ruby_version = ">= 1.9.2"
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = "newman"
end

