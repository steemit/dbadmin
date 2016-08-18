app_dir = File.expand_path("../..", __FILE__)
working_directory app_dir
worker_processes 2
preload_app true
timeout 30
listen 5000, tcp_nopush: true

GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

check_client_connection false

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
