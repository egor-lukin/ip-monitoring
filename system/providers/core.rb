# frozen_string_literal: true

Application.register_provider(:core) do
  prepare do
    require 'dry-validation'
    require 'dry/monads'
    require 'dry/monads/do'
    require_relative '../../lib/types'
  end

  start do
    Dry::Validation.load_extensions(:monads)
  end
end
