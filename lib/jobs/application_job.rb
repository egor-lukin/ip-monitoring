# frozen_string_literal: true

module Jobs
  class ApplicationJob
    include Sidekiq::Worker
  end
end
