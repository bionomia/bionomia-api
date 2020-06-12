require 'rake'
require 'bundler/setup'
require 'rspec/core/rake_task'
require './application'

task :default => :test
task :test => :spec

task :environment do
  require_relative './application'
end

if !defined?(RSpec)
  puts "spec targets require RSpec"
else
  desc "Run all examples"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*.rb'
  end
end
