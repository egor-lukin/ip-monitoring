# frozen_string_literal: true

module Operations
  class IcmpShellChecker
    include Import['operations.shell_executor']
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do.for(:call)

    PING_OUTPUT_PATTERN = %r{
\d+ packets transmitted, (\d+) received.*(?:\nrtt min/avg/max/mdev = [\d+.]+/([\d+.]+)/[\d+.]+/[\d+.]+ ms)?
}

    def call(ip_address:, started_at: DateTime.now)
      command = prepare_command(ip_address)
      output = yield exec_command(command)
      result = parse_shell_output(output)
      result.fmap { { **_1, started_at: } }
    end

    private

    def exec_command(command)
      Try { shell_executor.call(command) }.to_result
    end

    def prepare_command(ip_address)
      command = command_type(ip_address)

      "#{command} -q -W 1 -c 1 #{ip_address}"
    end

    def command_type(ip_address)
      return 'ping6' if ip_address.ipv6?

      'ping' if ip_address.ipv4?
    end

    def parse_shell_output(output)
      captures = output.match(PING_OUTPUT_PATTERN)
      return Failure(output) if captures.nil?

      received_packages = captures[1].to_i
      rtt = format_rtt(captures[2])

      dropped = received_packages != 1
      Success({ rtt:, dropped: })
    end

    def format_rtt(rtt)
      return nil if rtt.nil?

      (rtt.to_f * 1000).to_i
    end
  end
end
