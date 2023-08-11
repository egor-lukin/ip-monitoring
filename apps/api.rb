# frozen_string_literal: true

require 'grape'

module IpMonitoring
  class API < Grape::API
    include Dry::Monads[:result, :try]

    format :json

    # rubocop:disable Metrics/BlockLength
    resource :ips do
      params do
        requires :ip, type: Types::IP, coerce_with: -> { Types::IP.call(_1) }
        requires :enable, type: TrueClass
      end
      post do
        result = Operations::CreateIpAddress.new.call(**params)
        case result
        in Success
          value = result.value!

          { id: value.id }
        in Failure(ROM::SQL::UniqueConstraintError)
          status :unprocessable_entity
        in Failure
          status :internal_server_error
        end
      end

      params do
        requires :id, type: Integer
      end
      post ':id/enable' do
        result = Operations::EnableIpMonitoring.new.call(id: params[:id])
        case result
        in Success then
          status :ok
        in Failure(ROM::TupleCountMismatchError) then
          status :not_found
        in Failure(_) then
          status :internal_server_error
        end
      end

      params do
        requires :id, type: Integer
      end
      post ':id/disable' do
        result = Operations::DisableIpMonitoring.new.call(id: params[:id])
        case result
        in Success then
          status :ok
        in Failure(ROM::TupleCountMismatchError) then
          status :not_found
        in Failure(_) then
          status :internal_server_error
        end
      end

      params do
        requires :id, type: Integer
        requires :time_from, type: DateTime
        requires :time_to, type: DateTime
      end
      get ':id/stats' do
        result = Operations::CalculateStatistics.new.call(**params.symbolize_keys)
        case result
        in Success then
          result.value!.to_h
        in Failure(_) then
          status :internal_server_error
        end
      end

      params do
        requires :id, type: Integer
      end
      delete ':id' do
        result = Operations::DeactivateIpAddress.new.call(id: params[:id])
        case result
        in Success then
          status :ok
        in Failure(ROM::TupleCountMismatchError) then
          status :not_found
        in Failure(_) then
          status :internal_server_error
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
