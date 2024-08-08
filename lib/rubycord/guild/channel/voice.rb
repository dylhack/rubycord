# frozen_string_literal: true

module RubyCord
  #
  # Represents a voice channel.
  #
  class Guild
    class VoiceChannel < RubyCord::Guild::Channel
      include RubyCord::Internal::Connectable
      include RubyCord::Internal::Messageable

      # @return [Integer] The bitrate of the voice channel.
      attr_reader :bitrate
      # @return [Integer] The user limit of the voice channel.
      # @return [nil] If the user limit is not set.
      attr_reader :user_limit

      # @!attribute [r] members
      #   @return [Array<RubyCord::Guild::Member>] The members in the voice channel.
      # @!attribute [r] voice_states
      #   @return [Array<RubyCord::Guild::VoiceChannel::VoiceState>] The voice states associated with the voice channel.

      @channel_type = 2
      #
      # Edit the voice channel.
      # @async
      # @macro edit
      #
      # @param [String] name The name of the voice channel.
      # @param [Integer] position The position of the voice channel.
      # @param [Integer] bitrate The bitrate of the voice channel.
      # @param [Integer] user_limit The user limit of the voice channel.
      # @param [Symbol] rtc_region The region of the voice channel.
      # @param [String] reason The reason of editing the voice channel.
      #
      # @return [Async::Task<self>] The edited voice channel.
      #
      def edit(
        name: RubyCord::Unset,
        position: RubyCord::Unset,
        bitrate: RubyCord::Unset,
        user_limit: RubyCord::Unset,
        rtc_region: RubyCord::Unset,
        reason: nil
      )
        Async do
          payload = {}
          payload[:name] = name if name != RubyCord::Unset
          payload[:position] = position if position != RubyCord::Unset
          payload[:bitrate] = bitrate if bitrate != RubyCord::Unset
          payload[:user_limit] = user_limit if user_limit != RubyCord::Unset
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

      # @return [Array<RubyCord::Guild::VoiceChannel::VoiceState>]
      def voice_states
        guild.voice_states.select { |state| state.channel&.id == @id }
      end

      # @return [Array<RubyCord::Guild::Member>]
      def members
        voice_states.map(&:member)
      end

      private

      def _set_data(data)
        @bitrate = data[:bitrate]
        @user_limit = (data[:user_limit]).zero? ? nil : data[:user_limit]
        @rtc_region = data[:rtc_region]&.to_sym
        @video_quality_mode = data[:video_quality_mode] == 1 ? :auto : :full
        super
      end
    end
  end
end

require_relative "voice/voice_state"
