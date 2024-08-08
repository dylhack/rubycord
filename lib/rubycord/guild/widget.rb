# frozen_string_literal: true

module RubyCord
  #
  # Represents a guild widget.
  #
  class Guild
    class Widget < RubyCord::DiscordModel
      # @return [RubyCord::Snowflake] The guild ID.
      attr_reader :guild_id
      # @return [RubyCord::Snowflake] The channel ID.
      attr_reader :channel_id
      # @return [Boolean] Whether the widget is enabled.
      attr_reader :enabled
      alias enabled? enabled
      alias enable? enabled

      # @!attribute [r] channel
      #   @macro client_cache
      #   @return [RubyCord::Channel] The channel.
      # @!attribute [r] guild
      #   @macro client_cache
      #   @return [RubyCord::Guild] The guild.
      # @!attribute [r] json_url
      #   @return [String] The JSON URL.

      #
      # Initialize a new instance of the {Widget} class.
      # @private
      #
      # @param [RubyCord::Client] client The client.
      # @param [RubyCord::Snowflake] guild_id The guild ID.
      # @param [Hash] data The data from Discord.
      #
      def initialize(client, guild_id, data)
        @client = client
        @enabled = data[:enabled]
        @guild_id = Snowflake.new(guild_id)
        @channel_id = Snowflake.new(data[:channel_id])
      end

      def channel
        @client.channels[@channel_id]
      end

      #
      # Edit the widget.
      # @async
      # @macro edit
      #
      # @param [Boolean] enabled Whether the widget is enabled.
      # @param [RubyCord::Guild::Channel] channel The channel.
      # @param [String] reason The reason for editing the widget.
      #
      # @return [Async::Task<void>] The task.
      #
      def edit(enabled: nil, channel: nil, reason: nil)
        Async do
          payload = {}
          payload[:enabled] = enabled unless enabled.nil?
          payload[:channel_id] = channel.id if channel_id
          @client
            .http
            .request(
              RubyCord::Internal::Route.new(
                "/guilds/#{@guild_id}/widget",
                "//guilds/:guild_id/widget",
                :patch
              ),
              payload,
              audit_log_reason: reason
            )
            .wait
        end
      end

      alias modify edit

      def json_url
        "#{RubyCord::API_BASE_URL}/guilds/#{@guild_id}/widget.json"
      end

      #
      # Return iframe HTML of the widget.
      #
      # @param ["dark", "light"] theme The theme of the widget.
      # @param [Integer] width The width of the widget.
      # @param [Integer] height The height of the widget.
      #
      # @return [String] The iframe HTML.
      #
      def iframe(theme: "dark", width: 350, height: 500)
        # rubocop:disable Layout/LineLength
        [
          %(<iframe src="https://canary.discord.com/widget?id=#{@guild_id}&theme=#{theme}" width="#{width}" height="#{height}"),
          %(allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>)
        ].join
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
