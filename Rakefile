require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

$LOAD_PATH.unshift File.expand_path('../app', __FILE__)

require_relative 'lib/dynamodb-orm'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color', '--format', 'Fuubar']
end

task default: :spec
