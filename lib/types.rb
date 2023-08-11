# frozen_string_literal: true

require 'dry-types'
require 'resolv'

module Types
  include Dry.Types

  ipv4 = ->(input) { !(input =~ Resolv::IPv4::Regex).nil? }
  IPv4 = Types::String.constrained(case: ipv4)

  ipv6 = ->(input) { !(input =~ Resolv::IPv6::Regex).nil? }
  IPv6 = Types::String.constrained(case: ipv6)

  ip = ->(input) { ipv4.call(input) || ipv6.call(input) }
  IP = Types::String.constrained(case: ip)
end
