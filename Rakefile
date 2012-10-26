#!/usr/bin/env rake
SSH_USER = ENV['SSH_USER'] || ENV['USER']
SSH_HOST = ENV['SSH_HOST'] || 'duncanbeevers.com'
SSH_DIR  = ENV['SSH_DIR']  || '/home/duncanbeevers/duncanbeevers.com/mazeoid'

desc "Build the website from source"
task :build do
  puts "## Building website"
  status = system("middleman build --clean")
  puts status ? "OK" : "FAILED"
end

desc "Run the preview server at http://localhost:4567"
task :preview do
  system("middleman server")
end

desc "Deploy website via rsync"
task :deploy do
  puts "## Deploying website via rsync to #{SSH_HOST}"
  status = system("rsync -avze 'ssh' --delete build/ #{SSH_USER}@#{SSH_HOST}:#{SSH_DIR}")
  puts status ? "OK" : "FAILED"
end

desc "Run tests"
task :test do
  puts `mocha --compilers coffee:coffee-script test`
  raise 'javascript specs failed' if $?.to_i != 0
end