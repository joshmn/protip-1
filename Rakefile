require 'bundler/gem_tasks'
require 'fileutils'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end
task default: :test

namespace :test do
  task :coverage do
    require 'simplecov'
    SimpleCov.command_name 'Unit Tests'
    SimpleCov.start
    Rake::Task['test'].execute
  end
end

desc 'Compile protobuf sources to Ruby classes.'
task compile: :clean do
  ::Dir.glob('definitions/**/*.proto').each do |file|
    command = "protoc -Idefinitions --ruby_out=lib #{file}"
    puts command
    system command
  end
end

desc 'Remove generated Ruby classes.'
task :clean do
  ::Dir.glob('lib/protip/messages/*.rb').each do |file|
    ::FileUtils.rm(file)
  end
end


desc 'Open a console with this gem loaded'
task :console do
  require 'irb'
  require 'irb/completion'
  require 'protip'
  ARGV.clear
  IRB.start
end
