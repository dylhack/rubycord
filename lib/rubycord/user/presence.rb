# frozen_string_literal: true

module RubyCord
  #
  # Represents a presence of user.
  #
  class User::Presence < RubyCord::DiscordModel
    # @return [:online, :idle, :dnd, :offline] The status of the user.
    attr_reader :status
    # @return [Array<RubyCord::User::Activity>] The activities of the user.
    attr_reader :activities
    # @return [RubyCord::Client::User::Status] The client status of the user.
    attr_reader :client_status

    # @!attribute [r] user
    #   @return [RubyCord::User] The user of the presence.
    # @!attribute [r] guild
    #   @return [RubyCord::Guild] The guild of the presence.
    # @!attribute [r] activity
    #   @return [RubyCord::User::Activity] The activity of the presence.

    #
    # Initialize a presence.
    # @private
    #
    # @param [RubyCord::Client] client The client.
    # @param [Hash] data The data of the presence.
    #
    def initialize(client, data)
      @client = client
      @data = data
      _set_data(data)
    end

    def user
      @client.users[@user_id]
    end

    def guild
      @client.guilds[@guild_id]
    end

    def activity
      @activities[0]
    end

    def inspect
      "#<#{self.class} @status=#{@status.inspect} @activity=#{activity.inspect}>"
    end

    private

    def _set_data(data)
      @user_id = data[:user][:id]
      @guild_id = data[:guild_id]
      @status = data[:status].to_sym
      @activities = data[:activities].map { |a| User::Activity.new(a) }
      @client_status = Client::User::Status.new(data[:client_status])
    end
  end
end
