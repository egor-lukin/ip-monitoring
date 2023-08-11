# frozen_string_literal: true

module Operations
  class DisableIpMonitoring
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do.for(:call)

    include Import[
              'repos.ip_address_repo',
              'repos.ip_monitoring_period_repo',
            ]

    def call(id:, ended_at: DateTime.now)
      ip_address_repo.transaction do
        ip_address = yield fetch_active_ip_address(id)
        return Success(ip_address) if ip_address.active_monitoring_period.nil?

        yield complete_monitoring_period(ip_address.active_monitoring_period.id, ended_at)
        updated_ip_address = yield update_ip_address(id)

        Success(updated_ip_address)
      end
    end

    def fetch_active_ip_address(id)
      Try do
        # ip_address_repo.find_active_by_id(ip_address_id)
        ip_address_repo.ip_with_active_monitoring_period(id)
      end.to_result
    end

    def fetch_active_monitoring_period(ip_address_id)
      Try do
        ip_monitoring_period_repo.find_by(ip_address_id:, ended_at: nil)
      end.to_result
    end

    def complete_monitoring_period(ip_monitoring_id, ended_at)
      Try do
        ip_monitoring_period_repo.update(ip_monitoring_id, ended_at:)
      end.to_result
    end

    def update_ip_address(ip_address_id)
      Try do
        ip_address_repo.update(ip_address_id, monitoring_enabled: false)
      end.to_result
    end
  end
end
