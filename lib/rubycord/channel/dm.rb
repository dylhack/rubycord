# typed: true
# frozen_string_literal: true

module RubyCord
  #
  # Represents a DM channel.
  #
  class DMChannel < Channel
    include RubyCord::Internal::Messageable

    #
    # Returns the channel id to request.
    # @private
    #
    # @return [Async::Task<RubyCord::Snowflake>] A task that resolves to the channel id.
    #
    def channel_id
      Async { @id }
    end

    private

    def _set_data(data)
      @id = Snowflake.new(data)
    end
  end
end
