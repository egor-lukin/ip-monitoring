# frozen_string_literal: true

require_relative 'config/boot'
require_relative 'apps/api'

run IpMonitoring::API
