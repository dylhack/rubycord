# frozen_string_literal: true

module RubyCord
  #
  # Represents a vanity invite.
  #
  class Guild
    class VanityInvite < RubyCord::DiscordModel
      # @return [String] The vanity invite code.
      attr_reader :code
      # @return [Integer] The number of uses.
      attr_reader :uses

      # @!attribute [r] url
      #   @return [String] The vanity URL.

      #
      # Initialize a new instance of the {VanityInvite} class.
      # @private
      #
      # @param [RubyCord::Client] client The client.
      # @param [RubyCord::Guild] guild The guild.
      # @param [Hash] data The data of the invite.
      #
      def initialize(client, guild, data)
        @client = client
        @guild = guild
        @code = data[:code]
        @uses = data[:uses]
      end

      def url
        "https://discord.gg/#{@code}"
      end
    end
  end
end
