# frozen_string_literal: true

module Contracts
  class ApplicationContract < Dry::Validation::Contract
    config.messages.load_paths << 'config/locale.yml'
  end
end
