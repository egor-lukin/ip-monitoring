# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Operations::CheckIpAddress, db: true do
  subject(:check_ip) { described_class.new(icmp_checker:).call(id: ip_address.id) }

  let(:rtt) { Faker::Number.number(digits: 6) }
  let(:dropped) { false }
  let(:started_at) { Faker::Date.in_date_period }

  let(:icmp_checker) { instance_double(Operations::IcmpShellChecker) }
  let(:icmp_checker_result) { Dry::Monads::Success(rtt:, dropped:, started_at:) }
  let(:ip_address) { Factory[:ip_address] }

  before do
    allow(icmp_checker).to receive(:call).with(ip_address: ip_address.value).and_return(icmp_checker_result)
  end

  it 'succeeds' do
    expect(check_ip).to be_success
  end

  it 'creates ip_check' do
    expect(check_ip.value!).to include(
      rtt:,
      dropped:
    )
  end

  context 'with dropped package' do
    let(:rtt) { nil }
    let(:dropped) { true }

    it 'succeeds' do
      expect(check_ip).to be_success
    end

    it 'creates ip_check' do
      expect(check_ip.value!).to include(
        rtt: nil,
        dropped: true
      )
    end
  end

  context 'with failed request' do
    let(:icmp_checker_result) { Dry::Monads::Failure(RuntimeError) }

    it 'succeeds' do
      expect(check_ip).to be_failure
    end
  end
end
