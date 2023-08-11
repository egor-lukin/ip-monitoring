# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Operations::EnableIpMonitoring, db: true do
  subject(:enable_monitoring) { described_class.new.call(**params) }

  let(:monitoring_enabled_at) { DateTime.new(2023, 8, 11) }

  context 'without created ip' do
    let(:params) { { id: 1, started_at: monitoring_enabled_at } }

    it 'fails' do
      expect(enable_monitoring).to be_failure
    end

    it 'contains record not_found exception' do
      expect(enable_monitoring.failure).to be_a(ROM::TupleCountMismatchError)
    end
  end

  context 'with created ip with monitoring' do
    let!(:ip_address) { Factory[:ip_address] }
    let(:params) { { id: ip_address.id, started_at: monitoring_enabled_at } }

    it 'succeeds' do
      expect(enable_monitoring).to be_success
    end

    it 'enable monitoring' do
      enable_monitoring

      updated_ip_address = Application['repos.ip_address_repo'].by_id(ip_address.id)
      expect(updated_ip_address.monitoring_enabled).to be_truthy
    end
  end

  context 'with created ip without monitoring' do
    let!(:ip_address) { Factory[:ip_address, :without_monitoring] }
    let(:params) { { id: ip_address.id, started_at: monitoring_enabled_at } }

    it 'succeeds' do
      expect(enable_monitoring).to be_success
    end

    it 'enable monitoring' do
      enable_monitoring

      updated_ip_address = Application['repos.ip_address_repo'].by_id(ip_address.id)
      expect(updated_ip_address.monitoring_enabled).to be_truthy
    end
  end

  context 'with deleted ip' do
    let!(:ip_address) { Factory[:ip_address, :deleted] }
    let(:params) { { id: ip_address.id, started_at: monitoring_enabled_at } }

    it 'fails' do
      expect(enable_monitoring).to be_failure
    end
  end
end
