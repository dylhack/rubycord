# frozen_string_literal: true

module RubyCord
  #
  # Represents a voice region.
  #
  class Guild
    class VoiceRegion < RubyCord::DiscordModel
      # @return [RubyCord::Snowflake] The ID of the voice region.
      attr_reader :id
      # @return [String] The name of the voice region.
      attr_reader :name
      # @return [Boolean] Whether the voice region is VIP.
      attr_reader :vip
      alias vip? vip
      # @return [Boolean] Whether the voice region is optimal.
      attr_reader :optimal
      alias optimal? optimal
      # @return [Boolean] Whether the voice region is deprecated.
      attr_reader :deprecated
      alias deprecated? deprecated
      # @return [Boolean] Whether the voice region is custom.
      attr_reader :custom
      alias custom? custom

      #
      # Initialize a new instance of the VoiceRegion class.
      # @private
      #
      # @param [Hash] data The data of the voice region.
      #
      def initialize(data)
        @id = data[:id]
        @name = data[:name]
        @vip = data[:vip]
        @optimal = data[:optimal]
        @deprecated = data[:deprecated]
        @custom = data[:custom]
      end
    end
  end
end
