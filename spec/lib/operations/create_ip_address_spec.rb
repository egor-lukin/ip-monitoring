# frozen_string_literal: true

require 'spec_helper'

describe Operations::CreateIpAddress, db: true do
  subject(:create) { described_class.new.call(**params) }

  let(:ip) { '8.8.8.8' }
  let(:created_at) { Time.now.round }
  let(:monitoring_enabled) { false }

  let(:params) do
    {
      ip:,
      enable: monitoring_enabled,
      created_at:
    }
  end

  it 'succeeds' do
    expect(create).to be_success
  end

  it 'creates ip address' do
    create

    ip_address = Repos::IpAddressRepo.new.find_by!(value: ip)

    expect(ip_address).to have_attributes(
      monitoring_enabled: false,
      created_at: created_at.to_time
    )
  end

  context 'with enabled monitoring' do
    let(:monitoring_enabled) { true }

    it 'succeeds' do
      expect(create).to be_success
    end

    it 'creates ip address' do
      create

      ip_address = Repos::IpAddressRepo.new.find_by!(value: ip)

      expect(ip_address).to have_attributes(
        monitoring_enabled: true,
        created_at: created_at.to_time
      )
    end

    it 'creates ip monitoring period' do
      create

      ip_address = Repos::IpAddressRepo.new.find_by!(value: ip)
      ip_monitoring_period = Repos::IpMonitoringPeriodRepo.new.find_by!(ip_address_id: ip_address.id)

      expect(ip_monitoring_period).to have_attributes(
        started_at: created_at.to_time,
        ended_at: nil
      )
    end
  end

  context 'with invalid params' do
    let(:ip) { '8.8.8' }
    let(:monitoring_enabled) { true }

    it 'fails' do
      expect(create).to be_failure
    end
  end

  context 'when the same active ip address exists' do
    before do
      Factory[:ip_address, value: ip, deleted_at: nil]
    end

    it 'fails' do
      expect(create.failure).to be_a(ROM::SQL::UniqueConstraintError)
    end
  end

  context 'when the same deleted ip address exists' do
    before do
      Factory[:ip_address, value: ip, deleted_at: Time.now]
    end

    it 'succeeds' do
      expect(create).to be_success
    end
  end
end
