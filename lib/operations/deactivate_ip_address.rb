# frozen_string_literal: true

module Operations
  class DeactivateIpAddress
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do.for(:call)

    include Import[
              'contracts.create_ip_address',
              'repos.ip_address_repo',
              'repos.ip_monitoring_period_repo',
            ]

    def call(id:, ended_at: DateTime.now)
      ip_address_repo.transaction do
        ip_address = yield fetch_ip_address(id)
        return Success(ip_address) if ip_address.active_monitoring_period.nil?

        yield update_monitoring_period(ip_address.active_monitoring_period.id, ended_at)
        yield update_ip_address(ip_address.id, ended_at)

        Success(ip_address)
      end
    end

    def fetch_ip_address(id)
      Try do
        ip_address_repo.ip_with_active_monitoring_period(id)
      end.to_result
    end

    def update_monitoring_period(id, ended_at)
      Try do
        ip_monitoring_period_repo.update(id, ended_at:)
      end.to_result
    end

    def update_ip_address(id, ended_at)
      Try do
        ip_address_repo.update(id, deleted_at: ended_at, monitoring_enabled: false)
      end.to_result
    end
  end
end
