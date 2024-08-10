
# frozen_string_literal: true

module RubyCord
  #
  # Represents a message in Discord.
  #
  class Message < RubyCord::DiscordModel
    #
    # Represents message flag.
    # ## Flag fields
    # |Field|Value|
    # |-|-|
    # |`1 << 0`|`:crossposted`|
    # |`1 << 1`|`:crosspost`|
    # |`1 << 2`|`:supress_embeds`|
    # |`1 << 3`|`:source_message_deleted`|
    # |`1 << 4`|`:urgent`|
    # |`1 << 5`|`:has_thread`|
    # |`1 << 6`|`:ephemeral`|
    # |`1 << 7`|`:loading`|
    # |`1 << 8`|`:failed_to_mention_some_roles_in_thread`|
    #
    class Flag < RubyCord::Flag
      @bits = {
        crossposted: 0,
        crosspost: 1,
        supress_embeds: 2,
        source_message_deleted: 3,
        urgent: 4,
        has_thread: 5,
        ephemeral: 6,
        loading: 7,
        failed_to_mention_some_roles_in_thread: 8
      }.freeze
    end

    #
    # Represents reference of message.
    #
    class Reference
      # @return [RubyCord::Snowflake] The guild ID.
      attr_accessor :guild_id
      # @return [RubyCord::Snowflake] The channel ID.
      attr_accessor :channel_id
      # @return [RubyCord::Snowflake] The message ID.
      attr_accessor :message_id
      # @return [Boolean] Whether fail the request if the message is not found.
      attr_accessor :fail_if_not_exists

      alias fail_if_not_exists? fail_if_not_exists

      #
      # Initialize a new reference.
      #
      # @param [RubyCord::Snowflake] guild_id The guild ID.
      # @param [RubyCord::Snowflake] channel_id The channel ID.
      # @param [RubyCord::Snowflake] message_id The message ID.
      # @param [Boolean] fail_if_not_exists Whether fail the request if the message is not found.
      #
      def initialize(guild_id, channel_id, message_id, fail_if_not_exists: true)
        @guild_id = guild_id
        @channel_id = channel_id
        @message_id = message_id
        @fail_if_not_exists = fail_if_not_exists
      end

      #
      # Convert the reference to a hash.
      #
      # @return [Hash] The hash.
      #
      def to_hash
        {
          message_id: @message_id,
          channel_id: @channel_id,
          guild_id: @guild_id,
          fail_if_not_exists: @fail_if_not_exists
        }
      end

      #
      # Initialize a new reference from a hash.
      #
      # @param [Hash] data The hash.
      #
      # @return [RubyCord::Message::Reference] The reference.
      # @see https://discord.com/developers/docs/resources/channel#message-reference-object
      #
      def self.from_hash(data)
        new(
          data[:guild_id],
          data[:channel_id],
          data[:message_id],
          fail_if_not_exists: data[:fail_if_not_exists]
        )
      end

      def inspect
        "#<#{self.class.name} #{@channel_id}/#{@message_id}>"
      end
    end

    #
    # Represents a sticker.
    #
    class Sticker
      # @return [RubyCord::Snowflake] The sticker ID.
      attr_reader :id
      # @return [String] The sticker name.
      attr_reader :name
      # @return [Symbol] The sticker format.
      attr_reader :format

      def initialize(data)
        @id = Snowflake.new(data[:id])
        @name = data[:name]
        @format = RubyCord::Sticker::STICKER_FORMAT[data[:format]]
      end

      def inspect
        "#<#{self.class.name} #{@id}: #{@name} format=#{@format}>"
      end
    end

    #
    # Represents a interaction of message.
    #
    class Interaction < RubyCord::DiscordModel
      # @return [RubyCord::Snowflake] The interaction ID.
      attr_reader :id
      # @return [String] The name of command.
      # @return [nil] If the message is not a command.
      attr_reader :name
      # @return [Class] The type of interaction.
      attr_reader :type
      # @return [RubyCord::User] The user.
      attr_reader :user

      #
      # Initialize a new interaction.
      # @private
      #
      # @param [RubyCord::Client] client The client.
      # @param [Hash] data The interaction data.
      #
      def initialize(client, data)
        @id = Snowflake.new(data[:id])
        @name = data[:name]
        @type =
          (
            RubyCord::Interaction.descendants.find do |c|
              c.interaction_type == data[:type]
            end or raise "Unknown interaction type: #{data[:type]}"
          )
        @user = client.users[data[:user][:id]] || User.new(client, data[:user])
      end

      def inspect
        "<#{self.class.name} #{@id}: #{@name} type=#{@type} #{@user}>"
      end
    end

    #
    # Represents a activity of message.
    #
    class Activity < RubyCord::DiscordModel
      # @return [String] The name of activity.
      attr_reader :name
      # @return [Symbol] The type of activity.
      attr_reader :type

      # @private
      # @return [{Integer => Symbol}] The mapping of activity type.
      TYPES = {
        1 => :join,
        2 => :spectate,
        3 => :listen,
        5 => :join_request
      }.freeze

      #
      # Initialize a new activity.
      # @private
      #
      # @param [Hash] data The activity data.
      #
      def initialize(data)
        @name = data[:name]
        @type = TYPES[data[:type]]
      end

      # @return [String] Object class and attributes.
      def inspect
        "<#{self.class.name} #{@name} type=#{@type}>"
      end
    end
  end
end
