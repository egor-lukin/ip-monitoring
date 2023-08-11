# frozen_string_literal: true

module Operations
  class CalculateStatistics
    include Import['repos.ip_checks_repo']
    include Dry::Monads[:try]

    def call(time_from:, time_to:, id:)
      Try do
        ip_checks_repo.statistics(time_from, time_to, id)
      end.to_result
    end
  end
end
