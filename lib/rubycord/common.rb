
# frozen_string_literal: true

module RubyCord
  # @return [String] The API base URL.
  API_BASE_URL = "https://discord.com/api/v10"
  # @return [String] The version of discorb.
  VERSION = "0.1.0"
  # @return [Array<Integer>] The version array of discorb.
  VERSION_ARRAY = VERSION.split(".").map(&:to_i).freeze
  # @return [String] The user agent for the bot.
  USER_AGENT =
    "DiscordBot (https://discorb-lib.github.io #{VERSION}) Ruby/#{RUBY_VERSION}".freeze

  #
  # @abstract
  # Represents Discord model.
  #
  class DiscordModel
    def eql?(other)
      self == other
    end

    def ==(other)
      if respond_to?(:id) && other.respond_to?(:id)
        id == other.id
      else
        super
      end
    end

    def inspect
      "#<#{self.class}: #{@id}>"
    end

    # @private
    def hash
      @id.hash
    end
  end

  #
  # Represents Snowflake of Discord.
  #
  # @see https://discord.com/developers/docs/reference#snowflakes Official Discord API docs
  class Snowflake < String
    #
    # Initialize new snowflake.
    # @private
    #
    # @param [#to_s] value The value of the snowflake.
    #
    def initialize(value)
      @value = value.to_i
      super(@value.to_s)
    end

    # @!attribute [r] timestamp
    #   Timestamp of snowflake.
    #
    #   @return [Time] Timestamp of snowflake.
    #
    # @!attribute [r] worker_id
    #   Worker ID of snowflake.
    #
    #   @return [Integer] Worker ID of snowflake.
    #
    # @!attribute [r] process_id
    #   Process ID of snowflake.
    #
    #   @return [Integer] Process ID of snowflake.
    # @!attribute [r] increment
    #   Increment of snowflake.
    #
    #   @return [Integer] Increment of snowflake.
    # @!attribute [r] id
    #   Alias of to_s.
    #
    #   @return [String] The snowflake.

    #
    # Compares snowflake with other object.
    #
    # @param [#to_s] other Object to compare with.
    #
    # @return [Boolean] True if snowflake is equal to other object.
    #
    def ==(other)
      return false unless other.respond_to?(:to_s)

      to_s == other.to_s
    end

    #
    # Alias of {#==}.
    #
    def eql?(other)
      self == other
    end

    # Return hash of snowflake.
    def hash
      to_s.hash
    end

    def timestamp
      Time.at(((@value >> 22) + 1_420_070_400_000) / 1000.0)
    end

    # @return [Integer] Worker ID of snowflake.
    def worker_id
      (@value & 0x3E0000) >> 17
    end

    # @return [Integer] Process ID of snowflake.
    def process_id
      (@value & 0x1F000) >> 12
    end

    # @return [Integer] Increment of snowflake.
    def increment
      @value & 0xFFF
    end

    # @return [String] The object class and attributes.
    def inspect
      "#<#{self.class} #{self}>"
    end

    alias id to_s
    alias to_str to_s
  end

  # @return [Object] Object that represents unspecified value.
  #   This is used as a default value for optional parameters.
  Unset = Object.new
end
