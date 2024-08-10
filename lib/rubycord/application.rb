
# frozen_string_literal: true

module RubyCord
  #
  # Represents a Discord application.
  #
  class Application < RubyCord::DiscordModel
    # @return [RubyCord::Snowflake] The application's ID.
    attr_reader :id
    # @return [String] The application's name.
    attr_reader :name
    # @return [RubyCord::Asset, nil] The application's icon.
    attr_reader :icon
    # @return [String] The application's description.
    attr_reader :description
    # @deprecated Use {#description} instead.
    # @return [String] The application's summary.
    attr_reader :summary
    # @return [String] The application's public key.
    attr_reader :verify_key
    # @return [RubyCord::User] The application's owner.
    attr_reader :owner
    # @return [RubyCord::Application::Team, nil] The application's team.
    attr_reader :team
    # @return [Boolean] Whether the application's bot is public.
    attr_reader :bot_public
    alias bot_public? bot_public
    # @return [Boolean] Whether the application's bot requires a code grant.
    attr_reader :bot_require_code_grant
    alias bot_require_code_grant? bot_require_code_grant
    # @return [RubyCord::Application::Flag] The application's flags.
    attr_reader :flags

    #
    # Initializes a new instance of the Application class.
    # @private
    #
    # @param [RubyCord::Client] client The client that instantiated the object.
    # @param [Hash] data The data of the object.
    #
    def initialize(client, data)
      @client = client
      @data = data
      @id = Snowflake.new(data[:id])
      @name = data[:name]
      @icon = Asset.new(self, data[:icon]) if data.key?(:icon)
      @description = data[:description]
      @summary = data[:summary]
      @bot_public = data[:bot_public]
      @bot_require_code_grant = data[:bot_require_code_grant]
      @verify_key = data[:verify_key]
      @owner =
        @client.users[data[:owner][:id]] || User.new(@client, data[:owner])
      @team = data[:team] && Team.new(@client, data[:team])
      @flags = Flag.new(data[:flags])
    end

    # @return [String] Object class and attributes.
    def inspect
      "#<#{self.class} id=#{@id}>"
    end

    # @return [Boolean] Whether the application's bot can be invited by anyone.
    alias public? bot_public?

    alias require_code_grant? bot_require_code_grant?

    #
    # Represents a flag for an application.
    # ## Flag fields
    #
    # | Field|Value|
    # |---|---|
    # | `1 << 12` | `:gateway_presence` |
    # | `1 << 13` | `:gateway_presence_limited` |
    # | `1 << 14` | `:gateway_guild_members` |
    # | `1 << 15` | `:gateway_guild_members_limited` |
    # | `1 << 16` | `:verification_pending_guild_limit` |
    # | `1 << 17` | `:embedded` |
    # | `1 << 18` | `:gateway_message_content` |
    # | `1 << 19` | `:gateway_message_content_limited` |
    # | `1 << 23` | `:application_command_badge` |
    #
    class Flag < RubyCord::Flag
      @bits = {
        gateway_presence: 12,
        gateway_presence_limited: 13,
        gateway_guild_members: 14,
        gateway_guild_members_limited: 15,
        verification_pending_guild_limit: 16,
        embedded: 17,
        gateway_message_content: 18,
        gateway_message_content_limited: 19,
        application_command_badge: 23
      }
    end

    #
    # Represents a team for an application.
    #
    class Team < RubyCord::DiscordModel
      # @return [RubyCord::Snowflake] The team's ID.
      attr_reader :id
      # @return [RubyCord::Asset, nil] The team's icon.
      attr_reader :icon
      # @return [String] The team's name.
      attr_reader :name
      # @return [RubyCord::Snowflake] The team's owner's ID.
      attr_reader :owner_user_id
      # @return [RubyCord::Application::Team::Member] The team's member.
      attr_reader :members

      #
      # Initializes a new instance of the Team class.
      # @private
      #
      # @param [RubyCord::Client] client The client that instantiated the object.
      # @param [Hash] data The data of the object.
      #
      def initialize(client, data)
        @client = client
        @id = Snowflake.new(data[:id])
        @icon = Asset.new(self, data[:icon]) if data.key?(:icon)
        @name = data[:name]
        @owner_user_id = data[:owner_user_id]
        @members = data[:members].map { |m| Team::Member.new(@client, self, m) }
      end

      #
      # The team's owner.
      #
      # @return [RubyCord::Application::Team::Member] The team's owner.
      #
      def owner
        @members.find { |m| m.user.id == @owner_user_id }
      end

      # @return [String] Object class and attributes.
      def inspect
        "#<#{self.class} id=#{@id}>"
      end

      #
      # Represents a member of team.
      #
      class Member < RubyCord::DiscordModel
        # @return [RubyCord::User] The user.
        attr_reader :user
        # @return [Snowflake] The ID of member's team.
        attr_reader :team_id
        # @return [:invited, :accepted] The member's membership state.
        attr_reader :membership_state
        alias state membership_state
        # @return [Array<Symbol>] The permissions of the member.
        # @note This always return `:*`.
        attr_reader :permissions

        # @!attribute [r] pending?
        #   @return [Boolean] Whether the member is not joined to the team.
        # @!attribute [r] accepted?
        #   @return [Boolean] Whether the member accepted joining the team.
        # @!attribute [r] owner?
        #   @return [Boolean] Whether the member is the team's owner.

        # @private
        # @return [{Integer => Symbol}] The permission map.
        MEMBERSHIP_STATE = { 1 => :invited, 2 => :accepted }.freeze

        def initialize(client, team, data)
          @client = client
          @data = data
          @team = team
          @user =
            client.users[data[:user][:id]] || User.new(client, data[:user])
          @team_id = Snowflake.new(data[:team_id])
          @membership_state = MEMBERSHIP_STATE[data[:membership_state]]
          @permissions = data[:permissions].map(&:to_sym)
        end

        # @return [Boolean] Whether the member is not joined to the team.
        def pending?
          @membership_state == :invited
        end

        # @return [Boolean] Whether the member accepted joining the team.
        def accepted?
          @membership_state == :accepted
        end

        # @return [String] Object class and attributes.
        def inspect
          "#<#{self.class} id=#{@user.id}>"
        end

        # @return [Boolean] Whether the member is the team's owner.
        def owner?
          @team.owner_user_id == @user.id
        end

        def ==(other)
          super || @user == other
        end
      end
    end
  end
end
