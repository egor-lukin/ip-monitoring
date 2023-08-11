# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Operations::IcmpShellChecker do
  describe '#call' do
    subject(:check) { described_class.new(shell_executor:).call(ip_address:) }

    let(:shell_executor) { instance_double(Operations::ShellExecutor) }

    context 'with successful ipv4 icmp check' do
      let(:ip_address) { IPAddr.new('8.8.8.8') }
      let(:shell_input) { "ping -q -W 1 -c 1 #{ip_address}" }
      let(:shell_output) do
        <<~TEXT
          PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.

          --- 8.8.8.8 ping statistics ---
          1 packets transmitted, 1 received, 0% packet loss, time 0ms
          rtt min/avg/max/mdev = 70.825/70.825/70.825/0.000 ms
        TEXT
      end

      before do
        allow(shell_executor).to receive(:call).with(shell_input).and_return(shell_output)
      end

      it 'succeeds' do
        expect(check).to be_success
      end

      it 'returns rtt' do
        expect(check.value!).to include(
          rtt: 70_825,
          dropped: false
        )
      end
    end

    context 'with dropped ipv4 icmp check' do
      let(:ip_address) { IPAddr.new('8.8.8.8') }
      let(:shell_input) { "ping -q -W 1 -c 1 #{ip_address}" }
      let(:shell_output) do
        <<~TEXT
          PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.

          --- 8.8.8.9 ping statistics ---
          1 packets transmitted, 0 received, 100% packet loss, time 0ms
        TEXT
      end

      before do
        allow(shell_executor).to receive(:call).with(shell_input).and_return(shell_output)
      end

      it 'succeeds' do
        expect(check).to be_success
      end

      it 'returns rtt' do
        expect(check.value!).to include(
          rtt: nil,
          dropped: true
        )
      end
    end

    context 'with successful ipv6 icmp check' do
      let(:ip_address) { IPAddr.new('2a00:1450:4001:82b::200e') }

      let(:shell_input) { "ping6 -q -W 1 -c 1 #{ip_address}" }
      let(:shell_output) do
        <<~TEXT
          PING 2a00:1450:4001:82b::200e(2a00:1450:4001:82b::200e) 56 data bytes

          --- 2a00:1450:4001:82b::200e ping statistics ---
          1 packets transmitted, 1 received, 0% packet loss, time 0ms
          rtt min/avg/max/mdev = 32.818/32.818/32.818/0.000 ms
        TEXT
      end

      before do
        allow(shell_executor).to receive(:call).with(shell_input).and_return(shell_output)
      end

      it 'succeeds' do
        expect(check).to be_success
      end

      it 'returns rtt' do
        expect(check.value!).to include(
          rtt: 32_818,
          dropped: false
        )
      end
    end

    context 'with dropped ipv6 icmp check' do
      let(:ip_address) { IPAddr.new('2a00:1450:4001:82b::200e') }

      let(:shell_input) { "ping6 -q -W 1 -c 1 #{ip_address}" }
      let(:shell_output) do
        <<~TEXT
          PING 2a00:1450:4001:82b::200e(2a00:1450:4001:82b::200e) 56 data bytes

          --- 2a00:1450:4001:82b::200e ping statistics ---
          1 packets transmitted, 0 received, +1 errors, 100% packet loss, time 0ms
        TEXT
      end

      before do
        allow(shell_executor).to receive(:call).with(shell_input).and_return(shell_output)
      end

      it 'succeeds' do
        expect(check).to be_success
      end

      it 'returns rtt' do
        expect(check.value!).to include(
          rtt: nil,
          dropped: true
        )
      end
    end

    context 'with network problem' do
      let(:ip_address) { IPAddr.new('2a00:1450:4001:82b::200e') }

      let(:shell_input) { "ping6 -q -W 1 -c 1 #{ip_address}" }
      let(:shell_output) do
        <<~TEXT
          ping6: connect: Cannot assign requested address
        TEXT
      end

      before do
        allow(shell_executor).to receive(:call).with(shell_input).and_return(shell_output)
      end

      it 'fails' do
        expect(check).to be_failure
      end
    end
  end
end
