# frozen_string_literal: true

module Jobs
  class CheckAddressesJob < ApplicationJob
    include Import['repos.ip_address_repo']

    sidekiq_options queue: :default, retry: false

    def perform
      ip_address_repo.active.each do
        Jobs::CheckAddressJob.perform_async(_1.id)
      end
    end
  end
end
