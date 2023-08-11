# frozen_string_literal: true

module Operations
  class ShellExecutor
    def call(command)
      `#{command}`
    end
  end
end
