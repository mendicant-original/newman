# TASKS TAKEN FROM: https://github.com/rtomayko/rocco/blob/master/Rakefile
#
require 'rake/clean'

gem "redcarpet", "~> 1.17.2"

require 'rocco/tasks'
Rocco::make 'docs/', 'lib/**/*.rb'

desc 'Build rocco docs'
task :docs => :rocco
directory 'docs/'

task :default => :docs

desc 'Build docs and open in browser for the reading'
task :read => :docs do
  sh 'open docs/lib/subscription_counter.html'
end

desc 'Update gh-pages branch'
task :pages => ['docs/.git', :docs] do
  rev = `git rev-parse --short HEAD`.strip
  Dir.chdir 'docs' do
    sh "git add ."
    sh "git commit -m 'rebuild pages from #{rev}'" do |ok,res|
      if ok
        verbose { puts "gh-pages updated" }
        sh "git push -q origin HEAD:gh-pages"
      end
    end
  end
end
