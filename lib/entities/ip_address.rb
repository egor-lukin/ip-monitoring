# frozen_string_literal: true

module Entities
  class IpAddress < ROM::Struct
    def deleted?
      !deleted_at.nil?
    end

    def monitoring_enabled?
      monitoring_enabled
    end
  end
end
