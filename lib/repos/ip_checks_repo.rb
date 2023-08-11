# frozen_string_literal: true

module Repos
  class IpChecksRepo < ROM::Repository[:ip_checks]
    include Import['container']

    commands :create

    struct_namespace Entities

    def statistics(time_from, time_to, ip)
      ip_checks.statistics(time_from, time_to, ip)
    end
  end
end
