# frozen_string_literal: true

module Relations
  class IpAddresses < ROM::Relation[:sql]
    schema(:ip_addresses, infer: true) do
      associations do
        has_many :ip_monitoring_periods
        has_many :ip_checks

        has_one :ip_monitoring_periods, view: :active, as: :active_monitoring_period
      end
    end

    struct_namespace Entities
    auto_struct(true)

    def active
      where(deleted_at: nil)
    end
  end
end
