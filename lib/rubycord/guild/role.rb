
# frozen_string_literal: true

module RubyCord
  #
  # Represents a role in the guild.
  #
  class Guild
    class Role < RubyCord::DiscordModel
      include Comparable
      # @return [RubyCord::Snowflake] The ID of the role.
      attr_reader :id
      # @return [String] The name of the role.
      attr_reader :name
      # @return [RubyCord::Color] The color of the role.
      attr_reader :color
      # @return [RubyCord::Permission] The permissions of the role.
      attr_reader :permissions
      # @return [Integer] The position of the role.
      attr_reader :position
      # @return [RubyCord::Guild] The guild this role belongs to.
      attr_reader :guild
      # @return [Boolean] Whether the role is hoisted.
      attr_reader :hoist
      alias hoist? hoist
      # @return [Boolean] Whether the role is managed.
      attr_reader :managed
      alias managed? managed
      # @return [Boolean] Whether the role is a default role.
      attr_reader :mentionable
      alias mentionable? mentionable
      # @return [RubyCord::Asset, nil] The icon of the role.
      attr_reader :custom_icon
      # @return [RubyCord::Emoji, nil] The emoji of the role.
      attr_reader :emoji

      # @!attribute [r] mention
      #   @return [String] The mention of the role.
      # @!attribute [r] color?
      #   @return [Boolean] Whether the role has a color.
      # @!attribute [r] tag
      #   @return [RubyCord::Role::Tag] The tag of the role.
      # @!attribute [r] icon
      #   @return [RubyCord::Asset, RubyCord::Emoji] The icon of the role.

      #
      # Initializes a new role.
      # @private
      #
      # @param [RubyCord::Client] client The client.
      # @param [RubyCord::Guild] guild The guild the role belongs to.
      # @param [Hash] data The data of the role.
      #
      def initialize(client, guild, data)
        @client = client
        @guild = guild
        @data = {}
        _set_data(data)
      end

      def icon
        @custom_icon || @emoji
      end

      #
      # Compares two roles by their position.
      #
      # @param [RubyCord::Role] other The role to compare to.
      #
      # @return [Integer] -1 if the other role is higher, 0 if they are equal, 1 if the other role is lower.
      #
      def <=>(other)
        return nil unless other.is_a?(Role)

        @position <=> other.position
      end

      #
      # Formats the role as a string.
      #
      # @return [String] The formatted string.
      #
      def to_s
        "@#{@name}"
      end

      def mention
        "<@&#{@id}>"
      end

      def color?
        @color != 0
      end

      def inspect
        "#<#{self.class} @#{@name} id=#{@id}>"
      end

      #
      # Moves the role to a new position.
      # @async
      #
      # @param [Integer] position The new position.
      # @param [String] reason The reason for moving the role.
      #
      # @return [Async::Task<void>] The task.
      #
      def move(position, reason: nil)
        Async do
          @client
            .http
            .request(
              RubyCord::Internal::Route.new(
                "/guilds/#{@guild.id}/roles",
                "//guilds/:guild_id/roles",
                :patch
              ),
              { id: @id, position: },
              audit_log_reason: reason
            )
            .wait
        end
      end

      #
      # Edits the role.
      # @async
      # @macro edit
      #
      # @param [String] name The new name of the role.
      # @param [Integer] position The new position of the role.
      # @param [RubyCord::Color] color The new color of the role.
      # @param [Boolean] hoist Whether the role should be hoisted.
      # @param [Boolean] mentionable Whether the role should be mentionable.
      # @param [RubyCord::Image, RubyCord::UnicodeEmoji] icon The new icon or emoji of the role.
      # @param [String] reason The reason for editing the role.
      #
      # @return [Async::Task<void>] The task.
      #
      def edit(
        name: RubyCord::Unset,
        position: RubyCord::Unset,
        color: RubyCord::Unset,
        hoist: RubyCord::Unset,
        mentionable: RubyCord::Unset,
        icon: RubyCord::Unset,
        reason: nil
      )
        Async do
          payload = {}
          payload[:name] = name if name != RubyCord::Unset
          payload[:position] = position if position != RubyCord::Unset
          payload[:color] = color.to_i if color != RubyCord::Unset
          payload[:hoist] = hoist if hoist != RubyCord::Unset
          payload[:mentionable] = mentionable if mentionable != RubyCord::Unset
          if icon != RubyCord::Unset
            if icon.is_a?(RubyCord::Image)
              payload[:icon] = icon.to_s
            else
              payload[:unicode_emoji] = icon.to_s
            end
          end
          @client
            .http
            .request(
              RubyCord::Internal::Route.new(
                "/guilds/#{@guild.id}/roles/#{@id}",
                "//guilds/:guild_id/roles/:role_id",
                :patch
              ),
              payload,
              audit_log_reason: reason
            )
            .wait
        end
      end

      alias modify edit

      #
      # Deletes the role.
      #
      # @param [String] reason The reason for deleting the role.
      #
      # @return [Async::Task<void>] The task.
      #
      def delete(reason: nil)
        Async do
          @client
            .http
            .request(
              RubyCord::Internal::Route.new(
                "/guilds/#{@guild.id}/roles/#{@id}",
                "//guilds/:guild_id/roles/:role_id",
                :delete
              ),
              {},
              audit_log_reason: reason
            )
            .wait
        end
      end

      alias destroy delete

      def tag
        Tag.new(@tags)
      end

      alias tags tag

      #
      # Represents a tag of a role.
      #
      class Tag < RubyCord::DiscordModel
        # @return [RubyCord::Snowflake] The ID of the bot that owns the role.
        attr_reader :bot_id
        # @return [RubyCord::Snowflake] The ID of the integration.
        attr_reader :integration_id
        # @return [Boolean] Whether the tag is a premium subscriber role.
        attr_reader :premium_subscriber
        alias premium_subscriber? premium_subscriber
        # @!attribute [r] bot?
        #   @return [Boolean] Whether the role is a bot role.
        # @!attribute [r] integration?
        #   @return [Boolean] Whether the role is an integration role.

        #
        # Initializes a new tag.
        # @private
        #
        # @param [Hash] data The data of the tag.
        #
        def initialize(data)
          @bot_id = Snowflake.new(data[:bot_id])
          @integration_id = Snowflake.new(data[:integration_id])
          @premium_subscriber = data.key?(:premium_subscriber)
        end

        def bot?
          !@bot_id.nil?
        end

        def integration?
          !@integration_id.nil?
        end
      end

      private

      def _set_data(data)
        @id = Snowflake.new(data[:id])
        @name = data[:name]
        @color = Color.new(data[:color])
        @hoist = data[:hoist]
        @position = data[:position]
        @permissions = Permission.new(data[:permissions].to_i)
        @managed = data[:managed]
        @mentionable = data[:mentionable]
        @tags = data[:tags] || {}
        @custom_icon =
          (Asset.new(self, data[:icon], path: "role-icons/#{@id}") if data[:icon])
        @emoji =
          data[:unicode_emoji] ? UnicodeEmoji.new(data[:unicode_emoji]) : nil
        @guild.roles[@id] = self unless data[:no_cache]
        @data.update(data)
      end
    end
  end
end
