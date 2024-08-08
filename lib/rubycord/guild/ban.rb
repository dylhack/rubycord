module RubyCord
  #
  # Represents a ban.
  #
  class Guild
    class Ban < RubyCord::DiscordModel
      # @return [RubyCord::User] The user.
      attr_reader :user
      # @return [String] The reason for the ban.
      attr_reader :reason

      #
      # Initialize a new instance of the {Ban} class.
      # @private
      #
      # @param [RubyCord::Client] client The client.
      # @param [RubyCord::Guild] guild The guild.
      # @param [Hash] data The data from Discord.
      #
      def initialize(client, guild, data)
        @client = client
        @guild = guild
        @reason = data[:reason]
        @user =
          @client.users[data[:user][:id]] || User.new(@client, data[:user])
      end

      # @return [String] Object class and attributes.
      def inspect
        "<#{self.class.name} #{@user}>"
      end
    end
  end
end
