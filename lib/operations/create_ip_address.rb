# frozen_string_literal: true

module Operations
  class CreateIpAddress
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do.for(:call, :persist)

    include Import[
              'repos.ip_address_repo',
              'repos.ip_monitoring_period_repo',
              contract: 'contracts.create_ip_address',
            ]

    def call(created_at: Time.now.round, **params)
      values = yield validate(**params, created_at:)
      ip_address = yield persist(values)

      Success(ip_address)
    end

    private

    def validate(params)
      contract.call(params).to_monad
    end

    def persist(result)
      params = result.values.data
      need_enable_monitoring = params[:enable]
      ip_address_params = prepare_ip_address_params(params)

      ip_address_repo.transaction do
        ip_address = yield create_ip_address(ip_address_params)
        return Success(ip_address) unless need_enable_monitoring

        ip_monitoring_period_params = prepare_monitoring_period_params(ip_address.id, params[:created_at])
        yield create_monitoring_period(ip_monitoring_period_params)

        Success(ip_address)
      end
    end

    def prepare_ip_address_params(params)
      {
        value: params[:ip],
        monitoring_enabled: params[:enable],
        created_at: params[:created_at],
        deleted: false
      }
    end

    def prepare_monitoring_period_params(id, created_at)
      {
        ip_address_id: id,
        started_at: created_at
      }
    end

    def create_ip_address(params)
      Try do
        ip_address_repo.create(**params)
      end.to_result
    end

    def create_monitoring_period(params)
      Try do
        ip_monitoring_period_repo.create(**params)
      end.to_result
    end
  end
end
