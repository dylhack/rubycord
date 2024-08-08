
# frozen_string_literal: true

module RubyCord
  #
  # Represents a integration.
  #
  class Integration < RubyCord::DiscordModel
    # @return [RubyCord::Snowflake] The ID of the integration.
    attr_reader :id
    # @return [Symbol] The type of integration.
    attr_reader :type
    # @return [Boolean] Whether the integration is enabled.
    attr_reader :enabled
    alias enabled? enabled
    # @return [Boolean] Whether the integration is syncing.
    attr_reader :syncing
    alias syncing? syncing
    # @return [Boolean] Whether the integration is enabled emoticons.
    attr_reader :enable_emoticons
    alias enable_emoticons? enable_emoticons
    # @return [:remove_role, :kick] The behavior of the integration when it expires.
    attr_reader :expire_behavior
    # @return [Integer] The grace period of the integration.
    attr_reader :expire_grace_period
    # @return [RubyCord::User] The user for the integration.
    attr_reader :user
    # @return [RubyCord::Integration::Account] The account for the integration.
    attr_reader :account
    # @return [Integer] The number of subscribers for the integration.
    attr_reader :subscriber_count
    # @return [Boolean] Whether the integration is revoked.
    attr_reader :revoked
    alias revoked? revoked
    # @return [RubyCord::Application] The application for the integration.
    attr_reader :application

    # @!attribute [r] guild
    #   @macro client_cache
    #   @return [RubyCord::Guild] The guild this integration is in.

    # @private
    # @return [{Integer => String}] The map of the expire behavior.
    EXPIRE_BEHAVIOR = { 0 => :remove_role, 1 => :kick }.freeze

    #
    # Initialize a new integration.
    # @private
    #
    # @param [RubyCord::Client] client The client.
    # @param [Hash] data The data of the welcome screen.
    # @param [RubyCord::Snowflake] guild_id The ID of the guild.
    #
    def initialize(client, data, guild_id)
      @client = client
      @data = data
      @guild_id = guild_id
      _set_data(data)
    end

    def guild
      @client.guilds[@guild_id]
    end

    #
    # Delete the integration.
    # @async
    #
    # @param [String] reason The reason for deleting the integration.
    #
    # @return [Async::Task<void>] The task.
    #
    def delete(reason: nil)
      Async do
        @client
          .http
          .request(
            RubyCord::Internal::Route.new(
              "/guilds/#{@guild}/integrations/#{@id}",
              "//guilds/:guild_id/integrations/:integration_id",
              :delete
            ),
            {},
            audit_log_reason: reason
          )
          .wait
      end
    end

    alias destroy delete

    private

    def _set_data(data)
      @id = Snowflake.new(data[:id])
      @type = data[:type].to_sym
      @enabled = data[:enabled]
      @syncing = data[:syncing]
      @role_id = Snowflake.new(data[:role_id])
      @enable_emoticons = data[:enable_emoticons]
      @expire_behavior = EXPIRE_BEHAVIOR[data[:expire_behavior]]
      @expire_grace_period = data[:expire_grace_period]
      @user = @client.users[data[:user][:id]] or
        RubyCord::User.new(@client, data[:user])
      @account = Account.new(data[:account])
      @subscriber_count = data[:subscriber_count]
      @revoked = data[:revoked]
      @application = data[:application] and
        Application.new(@client, data[:application])
    end

    #
    # Represents an account for an integration.
    #
    class Account < RubyCord::DiscordModel
      # @return [String] The ID of the account.
      attr_reader :id
      # @return [String] The name of the account.
      attr_reader :name

      #
      # Initialize a new account.
      # @private
      #
      # @param [Hash] data The data from Discord.
      #
      def initialize(data)
        @id = data[:id]
        @name = data[:name]
      end
    end

    #
    # Represents an application for an integration.
    #
    class Application < RubyCord::DiscordModel
      # @return [RubyCord::Snowflake] The ID of the application.
      attr_reader :id
      # @return [String] The name of the application.
      attr_reader :name
      # @return [Asset] The icon of the application.
      # @return [nil] If the application has no icon.
      attr_reader :icon
      # @return [String] The description of the application.
      attr_reader :description
      # @return [String] The summary of the application.
      attr_reader :summary
      # @return [RubyCord::User] The bot user associated with the application.
      # @return [nil] If the application has no bot user.
      attr_reader :bot

      #
      # Initialize a new application.
      # @private
      #
      # @param [RubyCord::Client] client The client.
      # @param [Hash] data The data from Discord.
      #
      def initialize(client, data)
        @id = Snowflake.new(data[:id])
        @name = data[:name]
        @icon = data[:icon] && Asset.new(self, data[:icon])
        @description = data[:description]
        @summary = data[:summary]
        @bot = data[:bot] and
          client.users[data[:bot][:id]] || RubyCord::User.new(client, data[:bot])
      end
    end
  end
end
