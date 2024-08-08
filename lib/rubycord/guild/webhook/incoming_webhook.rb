module RubyCord
  #
  # Represents a bot created webhook.
  #
  class Guild
    class IncomingWebhook < Guild::Webhook
      # @!attribute [r] url
      #   @return [String] The URL of the webhook.

      #
      # Initializes the incoming webhook.
      # @private
      #
      # @param [RubyCord::Client] client The client.
      # @param [Hash] data The data.
      #
      def initialize(client, data)
        super
        @token = data[:token]
      end

      def url
        "https://discord.com/api/v9/webhooks/#{@id}/#{@token}"
      end
    end
  end
end
