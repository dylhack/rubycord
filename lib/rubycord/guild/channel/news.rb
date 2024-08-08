# frozen_string_literal: true

module RubyCord
  #
  # Represents a news channel (announcement channel).
  #
  class Guild
    class NewsChannel < RubyCord::Guild::TextChannel
      @channel_type = 5

      #
      # Follow the existing announcement channel from self.
      # @async
      #
      # @param [RubyCord::Guild::TextChannel] target The channel to follow to.
      # @param [String] reason The reason of following the channel.
      #
      # @return [Async::Task<void>] The task.
      #
      def follow_to(target, reason: nil)
        Async do
          @client
            .http
            .request(
              RubyCord::Internal::Route.new(
                "/channels/#{@id}/followers",
                "//channels/:channel_id/followers",
                :post
              ),
              { webhook_channel_id: target.id },
              audit_log_reason: reason
            )
            .wait
        end
      end
    end
  end
end
