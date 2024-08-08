module RubyCord
  #
  # Represents a webhook of channel following.
  #
  class Guild
    class FollowerWebhook < Guild::Webhook
      # @!attribute [r] source_guild
      #   Represents a source guild of follower webhook.
      #   @return [Guild, RubyCord::Guild::Webhook::FollowerWebhook::Guild] The source guild of follower webhook.
      # @!attribute [r] source_channel
      #   Represents a source channel of follower webhook.
      #   @return [Channel, RubyCord::Guild::Webhook::FollowerWebhook::Channel] The source channel of follower webhook.

      #
      # Initializes the follower webhook.
      # @private
      #
      # @param [RubyCord::Client] client The client.
      # @param [Hash] data The data of the follower webhook.
      #
      def initialize(client, data)
        super
        @source_guild = FollowerWebhook::Guild.new(data[:source_guild])
        @source_channel = FollowerWebhook::Channel.new(data[:source_channel])
      end

      def source_guild
        @client.guilds[@source_guild.id] || @source_guild
      end

      def source_channel
        @client.channels[@source_channel.id] || @source_channel
      end

      #
      # Represents a guild of follower webhook.
      #
      class Guild < RubyCord::DiscordModel
        # @return [RubyCord::Snowflake] The ID of the guild.
        attr_reader :id
        # @return [String] The name of the guild.
        attr_reader :name
        # @return [RubyCord::Asset] The icon of the guild.
        attr_reader :icon

        #
        # Initialize a new guild.
        # @private
        #
        # @param [Hash] data The data of the guild.
        #
        def initialize(data)
          @id = Snowflake.new(data[:id])
          @name = data[:name]
          @icon = Asset.new(self, data[:icon])
        end

        def inspect
          "#<#{self.class.name} #{@id}: #{@name}>"
        end
      end

      #
      # Represents a channel of follower webhook.
      #
      class Channel < RubyCord::DiscordModel
        # @return [RubyCord::Snowflake] The ID of the channel.
        attr_reader :id
        # @return [String] The name of the channel.
        attr_reader :name

        #
        # Initialize a new channel.
        # @private
        #
        # @param [Hash] data The data of the channel.
        #
        def initialize(data)
          @id = Snowflake.new(data[:id])
          @name = data[:name]
        end

        def inspect
          "#<#{self.class.name} #{@id}: #{@name}>"
        end
      end
    end
  end
end
