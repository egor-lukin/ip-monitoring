# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Operations::DisableIpMonitoring, db: true do
  subject(:disable_monitoring) { described_class.new.call(**params) }

  let(:monitoring_ended_at) { DateTime.new(2023, 8, 11) }

  context 'without created ip' do
    let(:params) { { id: 1, ended_at: monitoring_ended_at } }

    it 'failures' do
      expect(disable_monitoring).to be_failure
    end

    it 'contains record not_found exception' do
      expect(disable_monitoring.failure).to be_a(ROM::TupleCountMismatchError)
    end
  end

  context 'with created ip with monitoring' do
    let!(:ip_address) { Factory[:ip_address] }
    let(:params) { { id: ip_address.id, ended_at: monitoring_ended_at } }

    before do
      Factory[:ip_monitoring_period, :active, ip_address:]
    end

    it 'succeeds' do
      expect(disable_monitoring).to be_success
    end

    it 'disable monitoring' do
      disable_monitoring

      updated_ip_address = Repos::IpAddressRepo.new.by_id(ip_address.id)
      expect(updated_ip_address).to have_attributes(
        monitoring_enabled: false
      )
    end
  end

  context 'with created ip without monitoring' do
    let!(:ip_address) { Factory[:ip_address, :without_monitoring] }
    let(:params) { { id: ip_address.id, ended_at: monitoring_ended_at } }

    it 'succeeds' do
      expect(disable_monitoring).to be_success
    end

    it 'enable monitoring' do
      disable_monitoring

      updated_ip_address = Repos::IpAddressRepo.new.by_id(ip_address.id)
      expect(updated_ip_address.monitoring_enabled).to be_falsey
    end
  end

  context 'with deleted ip' do
    let!(:ip_address) { Factory[:ip_address, :deleted] }
    let(:params) { { id: ip_address.id, ended_at: monitoring_ended_at } }

    it 'fails' do
      expect(disable_monitoring).to be_failure
    end
  end
end
