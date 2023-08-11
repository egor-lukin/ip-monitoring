# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Operations::CalculateStatistics, db: true do
  subject(:calculate) { described_class.new.call(time_from:, time_to:, id: ip_address.id) }

  let(:ip_address) { Factory[:ip_address, value: '8.8.8.8'] }
  let(:time_from) { DateTime.new(2023, 7, 14) }
  let(:time_to) { DateTime.new(2023, 7, 15) }

  context 'with empty stat' do
    specify do
      expect(calculate.value!).to have_attributes(
        avg_rtt: nil,
        min_rtt: nil,
        max_rtt: nil,
        median_rtt: nil,
        dropped: nil
      )
    end
  end

  context 'with one active check' do
    before do
      Factory[:ip_monitoring_period, :active, ip_address:, started_at: time_from]
      Factory[:ip_check, ip_address:, started_at: time_from, rtt: 100, dropped: false]
    end

    specify do
      expect(calculate.value!).to have_attributes(
        avg_rtt: 100,
        min_rtt: 100,
        max_rtt: 100,
        median_rtt: 100,
        dropped: 0
      )
    end
  end

  context 'with multiple active checks' do
    before do
      Factory[:ip_monitoring_period, :active, ip_address:, started_at: time_from]
      Factory[:ip_check, ip_address:, started_at: time_from, rtt: 300, dropped: false]
      Factory[:ip_check, ip_address:, started_at: time_from, rtt: 200, dropped: false]
      Factory[:ip_check, :dropped, ip_address:, started_at: time_from]
    end

    specify do
      expect(calculate.value!).to have_attributes(
        avg_rtt: 250,
        min_rtt: 200,
        max_rtt: 300,
        median_rtt: 250,
        dropped: 33
      )
    end
  end
end
