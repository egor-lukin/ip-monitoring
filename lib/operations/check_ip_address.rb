# frozen_string_literal: true

module Operations
  class CheckIpAddress
    include Dry::Monads[:result, :try, :task]
    include Dry::Monads::Do.for(:call)

    include Import[
              ip_checks_repo: 'repos.ip_checks_repo',
              ip_address_repo: 'repos.ip_address_repo',
              icmp_checker: 'operations.icmp_shell_checker',
            ]

    def call(id:)
      ip_address = yield fetch_ip_address(id)
      return Failure(:ip_address_deleted) if ip_address.deleted?

      ip_check_params = yield send_icmp_packet(ip_address.value)

      ip_address_repo.transaction do
        yield save_ip_check(id, ip_check_params) if ip_address.monitoring_enabled?
        yield update_ip_address(id, ip_check_params[:dropped])

        Success(ip_check_params)
      end
    end

    private

    attr_reader :icmp_checker

    def fetch_ip_address(id)
      Try do
        ip_address_repo.by_id(id)
      end.to_result
    end

    def send_icmp_packet(value)
      Try do
        icmp_checker.call(ip_address: value)
      end.to_result
    end

    def save_ip_check(ip_address_id, ip_check_params)
      params = {
        **ip_check_params,
        ip_address_id:
      }

      Try do
        ip_checks_repo.create(params)
      end.to_result
    end

    def update_ip_address(id, dropped)
      Try do
        ip_address_repo.update(id, reachable: !dropped)
      end.to_result
    end
  end
end
