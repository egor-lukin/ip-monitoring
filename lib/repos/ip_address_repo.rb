# frozen_string_literal: true

module Repos
  class IpAddressRepo < ROM::Repository[:ip_addresses]
    include Import['container']

    commands :create, update: :by_pk

    struct_namespace Entities

    def ip_with_monitoring_periods(id)
      ip_addresses
        .by_pk(id)
        .combine(:ip_monitoring_periods)
        .to_a
    end

    def ip_with_active_monitoring_period(id)
      ip_addresses
        .active
        .by_pk(id)
        .combine(:active_monitoring_period)
        .one!
    end

    def find_active_by_id(id)
      ip_addresses.where(deleted_at: nil).by_pk(id).one!
    end

    def active
      ip_addresses.active.to_a
    end

    def by_id(id)
      ip_addresses.by_pk(id).one!
    end

    def find_by!(attributes)
      ip_addresses.where(attributes).one!
    end

    def find_by(attributes)
      ip_addresses.where(attributes).one
    end

    def where(conditions)
      ip_addresses.where(conditions).to_a
    end
  end
end
