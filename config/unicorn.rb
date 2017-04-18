worker_processes 8
timeout 36
preload_app true

app_dir = File.expand_path("../../..", __FILE__)

listen "#{app_dir}/tmp/unicorn.sock", :backlog => 2048
pid "#{app_dir}/tmp/unicorn.pid"

stderr_path "#{app_dir}/log/unicorn.log"
stdout_path "#{app_dir}/log/unicorn.log"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
