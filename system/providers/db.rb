# frozen_string_literal: true

Application.register_provider(:db) do
  prepare do
    require 'rom'
    require 'rom-sql'
  end

  start do
    env = ENV.fetch('APP_ENV', 'development')
    database_name = "ip_monitoring_#{env}"
    connection = Sequel.connect(ENV['DATABASE_URL'], database: database_name)

    register('db.connection', connection)

    config = ROM::Configuration.new(:sql, connection)
    config.register_relation(Relations::IpAddresses)
    config.register_relation(Relations::IpChecks)
    config.register_relation(Relations::IpMonitoringPeriods)

    register('db.config', config)
  end
end
