# frozen_string_literal: true

module RubyCord
  #
  # Represents a welcome screen.
  #
  class Guild
    class WelcomeScreen < RubyCord::DiscordModel
      # @return [String] The description of the welcome screen.
      attr_reader :description
      # @return [Array<RubyCord::Guild::WelcomeScreen::Channel>] The channels to display the welcome screen.
      attr_reader :channels
      # @return [RubyCord::Guild] The guild the welcome screen belongs to.
      attr_reader :guild

      #
      # Initializes the welcome screen.
      # @private
      #
      # @param [RubyCord::Client] client The client.
      # @param [RubyCord::Guild] guild The guild the welcome screen belongs to.
      # @param [Hash] data The data of the welcome screen.
      #
      def initialize(client, guild, data)
        @client = client
        @description = data[:description]
        @guild = guild
        @channels =
          data[:channels].map do |c|
            WelcomeScreen::Channel.new(
              client.channels[c[:channel_id]],
              c,
              c[:emoji_name] &&
                if c[:emoji_id]

                    client.emojis[c[:emoji_id]] ||
                      RubyCord::PartialEmoji.new(
                        { name: c[:emoji_name], id: c[:emoji_id] }
                      )

                else
                  RubyCord::UnicodeEmoji.new(c[:emoji_name])
                end
            )
          end
      end

      #
      # Represents a channel to display the welcome screen.
      #
      class Channel < RubyCord::DiscordModel
        # @return [String] The channel's name.
        attr_reader :description

        # @!attribute [r] emoji
        #   @return [RubyCord::Emoji] The emoji to display.
        # @!attribute [r] channel
        #   @macro client_cache
        #   @return [RubyCord::Channel] The channel to display the welcome screen.

        #
        # Initialize a new welcome screen channel.
        #
        # @param [RubyCord::Guild::TextChannel] channel The channel to display the welcome screen.
        # @param [String] description The channel's name.
        # @param [RubyCord::Emoji] emoji The emoji to display.
        #
        def initialize(channel, description, emoji)
          if description.is_a?(Hash)
            @screen = channel
            data = description
            @channel_id = Snowflake.new(data[:channel_id])
            @description = data[:description]
            @emoji_id = Snowflake.new(data[:emoji_id])
            @emoji_name = data[:emoji_name]
          else
            @channel_id = channel.id
            @description = description
            if emoji.is_a?(UnicodeEmoji)
              @emoji_id = nil
              @emoji_name = emoji.value
            else
              @emoji_id = emoji.id
              @emoji_name = emoji.name
            end
          end
        end

        #
        # Converts the channel to a hash.
        #
        # @return [Hash] The hash.
        # @see https://discord.com/developers/docs/resources/guild#welcome-screen-object
        #
        def to_hash
          {
            channel_id: @channel_id,
            description: @description,
            emoji_id: @emoji_id,
            emoji_name: @emoji_name
          }
        end

        def channel
          @screen.guild.channels[@channel_id]
        end

        def emoji
          if @emoji_id.nil?
            UnicodeEmoji.new(@emoji_name)
          else
            @screen.guild.emojis[@emoji_id]
          end
        end

        #
        # Edits the welcome screen.
        # @async
        # @macro edit
        #
        # @param [Boolean] enabled Whether the welcome screen is enabled.
        # @param [Array<RubyCord::Guild::WelcomeScreen::Channel>] channels The channels to display the welcome screen.
        # @param [String] description The description of the welcome screen.
        # @param [String] reason The reason for editing the welcome screen.
        #
        # @return [Async::Task<void>] The task.
        #
        def edit(
          enabled: RubyCord::Unset,
          channels: RubyCord::Unset,
          description: RubyCord::Unset,
          reason: nil
        )
          Async do
            payload = {}
            payload[:enabled] = enabled unless enabled == RubyCord::Unset
            payload[:welcome_channels] = channels.map(
              &:to_hash
            ) unless channels == RubyCord::Unset
            payload[:description] = description unless description ==
              RubyCord::Unset
            @client
              .http
              .request(
                RubyCord::Internal::Route.new(
                  "/guilds/#{@guild.id}/welcome-screen",
                  "//guilds/:guild_id/welcome-screen",
                  :patch
                ),
                payload,
                audit_log_reason: reason
              )
              .wait
          end
        end
      end
    end
  end
end
