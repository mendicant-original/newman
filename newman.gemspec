Gem::Specification.new do |s|
  s.name = "newman"
  s.version = "0.0.1"
  s.platform = Gem::Platform::RUBY
  s.authors = ["Gregory Brown"]
  s.email = ["gregory.t.brown@gmail.com"]
  s.homepage = "http://github.com/mendicant-university/newman"
  s.summary = "A microframework for mail-centric applications"
  s.description = "A microframework for mail-centric applications"
  s.files = %w[README.md]

  #Dir.glob("{bin,lib,test,example,doc,data}/**/*") + 
  #%w(README.md LICENSE RULES.txt CHANGELOG)
  s.require_path = 'lib'

  s.required_ruby_version = ">= 1.9.2"
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = "newman"
end

