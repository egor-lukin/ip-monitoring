# frozen_string_literal: true

require 'dry/system'
require 'dry/system/container'
require 'dry/auto_inject'

require 'sidekiq'

class Application < Dry::System::Container
  use :zeitwerk

  configure do |config|
    config.root = File.expand_path('..', __dir__)

    config.component_dirs.add 'lib'
  end
end

Import = Dry::AutoInject(Application)
