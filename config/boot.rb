# frozen_string_literal: true

ENV['APP_ENV'] ||= 'development'

require 'bundler'
Bundler.setup(:default, ENV['APP_ENV'])

require_relative '../system/container'
Application.finalize!

result = Operations::IcmpShellChecker.new.call(ip_address: IPAddr.new('8.8.8.8'))
raise result.failure if result.failure?
