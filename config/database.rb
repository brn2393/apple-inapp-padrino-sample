Sequel.default_timezone = :utc
Sequel::Model.raise_on_save_failure = false # Do not throw exceptions on failure
Sequel::Model.db = case Padrino.env
                   when :development then Sequel.connect(
                     'postgres://localhost/sample_db?user=yoda&password=yoda',
                     #  loggers: [Logger.new($stdout)],
                     loggers: [logger],
                     sslmode: 'disable',
                     reconnect: true
                   )
                   when :production  then Sequel.connect('your_production_db_url', loggers: [logger])
                   when :test        then Sequel.connect('your_test_db_url', loggers: [logger])
                   end
Sequel.extension :core_extensions
Sequel::Model.db.extension :connection_validator
Sequel::Model.db.pool.connection_validation_timeout = -1
