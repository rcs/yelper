require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--format nested --color']
end

desc "Run RSpec with code coverage"
task :coverage do
  ENV['COVERAGE'] = "true"
  Rake::Task["spec"].execute
end
