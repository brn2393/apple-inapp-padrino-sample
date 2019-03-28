workers Integer(ENV['WEB_CONCURRENCY'] || 1)
threads_count = Integer(ENV['PADRINO_MAX_THREADS'] || 1)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

before_fork do
  Sequel::Model.db.disconnect if defined?(Sequel::Model)
end
