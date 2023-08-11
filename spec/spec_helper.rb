# frozen_string_literal: true

require 'rack/test'
require 'rom-factory'
require 'pry'
require 'database_cleaner-sequel'

require_relative '../config/boot'

Factory = ROM::Factory.configure do |config|
  config.rom = Application['container']
end

Dir["#{File.dirname(__FILE__)}/support/factories/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = :random

  config.before(:each, db: true) do
    DatabaseCleaner[:sequel].start
  end

  config.append_after(:each, db: true) do |_ex|
    DatabaseCleaner[:sequel].clean
  end
end
