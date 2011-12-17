# -*- ruby -*-

require './lib/cli_test'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.version = CLITest::VERSION
  gem.name = "cli_test"
  gem.summary = "Runs commandline binaries from your test suite"
  gem.email = "me@julik.nl"
  gem.homepage = "http://github.com/julik/cli_test"
  gem.authors = ["Julik Tarkhanov"]
  
  # Do not package invisibles
  gem.files.exclude ".*"
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
desc "Run all tests"
Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

task :default => [ :test ]
