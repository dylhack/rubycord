module RubyCord
  #
  # Represents an activity of a user.
  #
  class User::Activity < RubyCord::DiscordModel
    # @return [String] The name of the activity.
    attr_reader :name
    # @return [:game, :streaming, :listening, :watching, :custom, :competing] The type of the activity.
    attr_reader :type
    # @return [String] The url of the activity.
    attr_reader :url
    # @return [Time] The time the activity was created.
    attr_reader :created_at
    alias started_at created_at
    # @return [RubyCord::User::Activity::Timestamps] The timestamps of the activity.
    attr_reader :timestamps
    # @return [RubyCord::Snowflake] The application id of the activity.
    attr_reader :application_id
    # @return [String] The details of the activity.
    attr_reader :details
    # @return [String] The state of party.
    attr_reader :state
    # @return [RubyCord::Emoji] The emoji of the activity.
    attr_reader :emoji
    # @return [RubyCord::User::Activity::Party] The party of the activity.
    # @return [nil] If the activity is not a party activity.
    attr_reader :party
    # @return [RubyCord::User::Activity::Asset] The assets of the activity.
    # @return [nil] If the activity has no assets.
    attr_reader :assets
    # @return [RubyCord::Guild::StageChannel::StageInstance] The instance of the activity.
    # @return [nil] If the activity is not a stage activity.
    attr_reader :instance
    # @return [Array<RubyCord::User::Activity::Button>] The buttons of the activity.
    # @return [nil] If the activity has no buttons.
    attr_reader :buttons
    # @return [RubyCord::User::Activity::Flag] The flags of the activity.
    attr_reader :flags

    # @private
    # @return [{Integer => Symbol}] The mapping of activity types.
    ACTIVITY_TYPES = {
      0 => :game,
      1 => :streaming,
      2 => :listening,
      3 => :watching,
      4 => :custom,
      5 => :competing
    }.freeze

    #
    # Initialize the activity.
    # @private
    #
    # @param [Hash] data The activity data.
    #
    def initialize(data)
      @name = data[:name]
      @type = ACTIVITY_TYPES[data[:type]]
      @url = data[:url]
      @created_at = Time.at(data[:created_at])
      @timestamps = data[:timestamps] && Timestamps.new(data[:timestamps])
      @application_id =
        data[:application_id] && Snowflake.new(data[:application_id])
      @details = data[:details]
      @state = data[:state]
      @emoji =
        if data[:emoji]
          if data[:emoji][:id].nil?
            UnicodeEmoji.new(data[:emoji][:name])
          else
            PartialEmoji.new(data[:emoji])
          end
        end
      @party = data[:party] && Party.new(data[:party])
      @assets = data[:assets] && Asset.new(data[:assets])
      @instance = data[:instance]
      @buttons = data[:buttons]&.map { |b| Component::Button.new(b) }
      @flags = data[:flags] && Flag.new(data[:flags])
    end

    #
    # Convert the activity to a string.
    #
    # @return [String] The string representation of the activity.
    #
    def to_s
      case @type
      when :game
        "Playing #{@name}"
      when :streaming
        "Streaming #{@details}"
      when :listening
        "Listening to #{@name}"
      when :watching
        "Watching #{@name}"
      when :custom
        "#{@emoji} #{@state}"
      when :competing
        "Competing in #{@name}"
      else
        raise "Unknown activity type: #{@type}"
      end
    end

    #
    # Represents the timestamps of an activity.
    #
    class Timestamps < RubyCord::DiscordModel
      # @return [Time] The start time of the activity.
      attr_reader :start
      # @return [Time] The end time of the activity.
      attr_reader :end

      #
      # Initialize the timestamps.
      # @private
      #
      # @param [Hash] data The timestamps data.
      #
      def initialize(data)
        @start = data[:start] && Time.at(data[:start])
        @end = data[:end] && Time.at(data[:end])
      end
    end

    #
    # Represents the party of an activity.
    #
    class Party < RubyCord::DiscordModel
      # @return [String] The id of the party.
      attr_reader :id

      # @!attribute [r] current_size
      #   @return [Integer] The current size of the party.
      # @!attribute [r] max_size
      #   @return [Integer] The max size of the party.

      #
      # Initialize the party.
      # @private
      #
      # @param [Hash] data The party data.
      #
      def initialize(data)
        @id = data[:id]
        @size = data[:size]
      end

      def current_size
        @size[0]
      end

      def max_size
        @size[1]
      end
    end

    #
    # Represents the assets of an activity.
    #
    class Asset < RubyCord::DiscordModel
      # @return [String] The large image ID or URL of the asset.
      attr_reader :large_image
      alias large_id large_image
      # @return [String] The large text of the activity.
      attr_reader :large_text
      # @return [String] The small image ID or URL of the activity.
      attr_reader :small_image
      alias small_id small_image
      # @return [String] The small text of the activity.
      attr_reader :small_text

      def initialize(data)
        @large_image = data[:large_image]
        @large_text = data[:large_text]
        @small_image = data[:small_image]
        @small_text = data[:small_text]
      end
    end

    #
    # Represents the flags of an activity.
    # ## Flag fields
    # |`1 << 0`|`:instance`|
    # |`1 << 1`|`:join`|
    # |`1 << 2`|`:spectate`|
    # |`1 << 3`|`:join_request`|
    # |`1 << 4`|`:sync`|
    # |`1 << 5`|`:play`|
    #
    class Flag < RubyCord::Flag
      @bits = {
        instance: 0,
        join: 1,
        spectate: 2,
        join_request: 3,
        sync: 4,
        play: 5
      }
    end

    #
    # Represents a secrets of an activity.
    #
    class Secrets < RubyCord::DiscordModel
      # @return [String] The join secret of the activity.
      attr_reader :join
      # @return [String] The spectate secret of the activity.
      attr_reader :spectate
      # @return [String] The match secret of the activity.
      attr_reader :match

      #
      # Initialize the secrets.
      # @private
      #
      # @param [Hash] data The secrets data.
      #
      def initialize(data)
        @join = data[:join]
        @spectate = data[:spectate]
        @match = data[:match]
      end
    end

    #
    # Represents a button of an activity.
    #
    class Button < RubyCord::DiscordModel
      # @return [String] The text of the button.
      attr_reader :label
      # @return [String] The URL of the button.
      attr_reader :url
      alias text label

      #
      # Initialize the button.
      # @private
      #
      # @param [Hash] data The button data.
      #
      def initialize(data)
        @label = data[0]
        @url = data[1]
      end
    end
  end
end
