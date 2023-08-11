# frozen_string_literal: true

module Operations
  class EnableIpMonitoring
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do.for(:call)

    include Import[
              'repos.ip_address_repo',
              'repos.ip_monitoring_period_repo',
            ]

    def call(id:, started_at: DateTime.now)
      ip_address_repo.transaction do
        ip_address = yield fetch_ip_address(id)
        return Success([ip_address]) unless ip_address.active_monitoring_period.nil?

        monitoring_period = yield create_monitoring_period(ip_address.id, started_at)
        ip_address = yield activate_ip_address(id)

        Success([ip_address, monitoring_period])
      end
    end

    def fetch_ip_address(ip_address_id)
      Try do
        ip_address_repo.ip_with_active_monitoring_period(ip_address_id)
      end.to_result
    end

    def activate_ip_address(ip_address_id)
      Try do
        ip_address_repo.update(ip_address_id, monitoring_enabled: true)
      end.to_result
    end

    def create_monitoring_period(ip_address_id, started_at)
      Try do
        ip_monitoring_period_repo.create(ip_address_id:,
                                         started_at:)
      end.to_result
    end
  end
end
