module RubyCord
  #
  # Represents a webhook from URL.
  #
  class Guild
    class URLWebhook < Guild::Webhook
      # @return [String] The URL of the webhook.
      attr_reader :url

      #
      # Initializes the webhook from URL.
      #
      # @param [String] url The URL of the webhook.
      # @param [RubyCord::Client] client The client to associate with the webhook.
      #
      def initialize(url, client: nil)
        @url = url
        @token = ""
        @http = RubyCord::Client::HTTP.new(client || RubyCord::Client.new)
      end
    end
  end
end
