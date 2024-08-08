
# frozen_string_literal: true

module RubyCord
  # @private
  module Utils
    def try(object, message, ...)
      object.respond_to?(message) ? object.send(message, ...) : object
    end

    module_function :try
  end
end
