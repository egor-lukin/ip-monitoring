# frozen_string_literal: true

module Contracts
  class CreateIpAddress < ApplicationContract
    params do
      required(:ip).filled(Types::IP)
      required(:enable).filled(:bool)
      required(:created_at).filled(:time)
    end
  end
end
