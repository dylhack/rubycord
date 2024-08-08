# frozen_string_literal: true

module RubyCord
  #
  # Represents a stage channel.
  #
  class Guild
    class StageChannel < RubyCord::Guild::Channel
      include RubyCord::Internal::Connectable

      # @return [Integer] The bitrate of the voice channel.
      attr_reader :bitrate
      # @return [Integer] The user limit of the voice channel.
      attr_reader :user_limit
      #
      # @private
      # @return [RubyCord::Internal::Dictionary{RubyCord::Snowflake => RubyCord::Guild::StageChannel::StageInstance}]
      #   The stage instances associated with the stage channel.
      #
      attr_reader :stage_instances

      # @!attribute [r] stage_instance
      #   @return [RubyCord::Guild::StageChannel::StageInstance] The stage instance of the channel.

      @channel_type = 13
      #
      # Initialize a new stage channel.
      # @private
      #
      def initialize(...)
        @stage_instances = Internal::Dictionary.new
        super
      end

      # @return [RubyCord::Guild::StageChannel::StageInstance, nil] An active stage in the channel.
      def stage_instance
        @stage_instances[0]
      end

      #
      # Edit the stage channel.
      # @async
      # @macro edit
      #
      # @param [String] name The name of the stage channel.
      # @param [Integer] position The position of the stage channel.
      # @param [Integer] bitrate The bitrate of the stage channel.
      # @param [Symbol] rtc_region The region of the stage channel.
      # @param [String] reason The reason of editing the stage channel.
      #
      # @return [Async::Task<self>] The edited stage channel.
      #
      def edit(
        name: RubyCord::Unset,
        position: RubyCord::Unset,
        bitrate: RubyCord::Unset,
        rtc_region: RubyCord::Unset,
        reason: nil
      )
        Async do
          payload = {}
          payload[:name] = name if name != RubyCord::Unset
          payload[:position] = position if position != RubyCord::Unset
          payload[:bitrate] = bitrate if bitrate != RubyCord::Unset
          payload[:rtc_region] = rtc_region if rtc_region != RubyCord::Unset
          @client
            .http
            .request(
              RubyCord::Internal::Route.new("/channels/#{@id}", "//channels/:channel_id", :patch),
              payload,
              audit_log_reason: reason
            )
            .wait
          self
        end
      end

      alias modify edit

      #
      # Start a stage instance.
      # @async
      #
      # @param [String] topic The topic of the stage instance.
      # @param [Boolean] public Whether the stage instance is public or not.
      # @param [String] reason The reason of starting the stage instance.
      #
      # @return [Async::Task<RubyCord::Guild::StageChannel::StageInstance>] The started stage instance.
      #
      def start(topic, public: false, reason: nil)
        Async do
          _resp, data =
            @client
              .http
              .request(
                RubyCord::Internal::Route.new("/stage-instances", "//stage-instances", :post),
                { channel_id: @id, topic:, public: public ? 2 : 1 },
                audit_log_reason: reason
              )
              .wait
          StageInstance.new(@client, data)
        end
      end

      #
      # Fetch a current stage instance.
      # @async
      #
      # @return [Async::Task<RubyCord::Guild::StageChannel::StageInstance>] The current stage instance.
      # @return [Async::Task<nil>] If there is no current stage instance.
      #
      def fetch_stage_instance
        Async do
          _resp, data =
            @client
              .http
              .request(
                RubyCord::Internal::Route.new(
                  "/stage-instances/#{@id}",
                  "//stage-instances/:stage_instance_id",
                  :get
                )
              )
              .wait
        rescue RubyCord::NotFoundError
          nil
        else
          StageInstance.new(@client, data)
        end
      end

      def voice_states
        guild.voice_states.select { |state| state.channel&.id == @id }
      end

      # @return [Array<RubyCord::Guild::Member>]
      def members
        voice_states.map(&:member)
      end

      # @return [Array<RubyCord::Guild::Member>]
      def speakers
        voice_states.reject(&:suppress?).map(&:member)
      end

      # @return [Array<RubyCord::Guild::Member>]
      def audiences
        voice_states.filter(&:suppress?).map(&:member)
      end

      private

      def _set_data(data)
        @bitrate = data[:bitrate]
        @user_limit = data[:user_limit]
        @topic = data[:topic]
        @rtc_region = data[:rtc_region]&.to_sym
        super
      end
    end
  end
end
