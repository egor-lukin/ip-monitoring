# frozen_string_literal: true

module Relations
  class IpMonitoringPeriods < ROM::Relation[:sql]
    schema(:ip_monitoring_periods, infer: true) do
      associations do
        belongs_to :ip_address
      end
    end

    def active
      where(ended_at: nil)
    end
  end
end
