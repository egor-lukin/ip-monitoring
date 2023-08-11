# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Operations::DeactivateIpAddress, db: true do
  describe '#call' do
    subject(:deactivate) { described_class.new.call(**params) }

    let(:ended_at) { Time.now.round }

    context 'without created ip' do
      let(:params) { { id: 1, ended_at: } }

      it 'fails' do
        expect(deactivate).to be_failure
      end
    end

    context 'with enabled monitoring' do
      let!(:ip_address) { Factory[:ip_address, monitoring_enabled: true] }
      let(:params) { { id: ip_address.id, ended_at: } }

      before do
        Factory[:ip_monitoring_period, :active, ip_address:]
      end

      it 'succeeds' do
        expect(deactivate).to be_success
      end

      it 'disables monitoring' do
        deactivate

        updated_ip_address = Repos::IpAddressRepo.new.by_id(ip_address.id)

        expect(updated_ip_address).to have_attributes(
          monitoring_enabled: false,
          deleted_at: ended_at
        )
      end

      it 'ends monitoring period' do
        deactivate

        updated_ip_address = Repos::IpAddressRepo.new.ip_with_monitoring_periods(ip_address.id).last
        ip_monitoring = updated_ip_address.ip_monitoring_periods.last

        expect(ip_monitoring).to have_attributes(
          ended_at:
        )
      end
    end
  end
end
