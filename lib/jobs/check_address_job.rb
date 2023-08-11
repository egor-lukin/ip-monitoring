# frozen_string_literal: true

module Jobs
  class CheckAddressJob < Jobs::ApplicationJob
    include Import['operations.check_ip_address']

    sidekiq_options queue: :default, retry: false

    def perform(ip_address_id)
      check_ip_address.call(id: ip_address_id)
    end
  end
end
