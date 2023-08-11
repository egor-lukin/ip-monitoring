# frozen_string_literal: true

module Repos
  class IpMonitoringPeriodRepo < ROM::Repository[:ip_monitoring_periods]
    include Import['container']

    commands :create, update: :by_pk

    struct_namespace Entities

    def find_by!(attributes)
      ip_monitoring_periods.where(attributes).one!
    end

    def find_by(attributes)
      ip_monitoring_periods.where(attributes).one
    end

    def where(conditions)
      ip_monitoring_periods.where(conditions).to_a
    end
  end
end
