# frozen_string_literal: true

module RubyCord
  #
  # Represents a state of user in voice channel.
  #
  class Guild
    class VoiceChannel
      class VoiceState < RubyCord::DiscordModel
        # @return [RubyCord::Guild::Member] The member associated with this voice state.
        attr_reader :member
        # @return [RubyCord::Snowflake] The ID of the guild this voice state is for.
        attr_reader :session_id
        # @return [Time] The time at which the user requested to speak.
        attr_reader :request_to_speak_timestamp
        # @return [Boolean] Whether the user is deafened.
        attr_reader :self_deaf
        alias self_deaf? self_deaf
        # @return [Boolean] Whether the user is muted.
        attr_reader :self_mute
        alias self_mute? self_mute
        # @return [Boolean] Whether the user is streaming.
        attr_reader :self_stream
        alias stream? self_stream
        alias live? stream?
        # @return [Boolean] Whether the user is video-enabled.
        attr_reader :self_video
        alias video? self_video
        # @return [Boolean] Whether the user is suppressed. (Is at audience)
        attr_reader :suppress
        alias suppress? suppress

        # @!attribute [r] deaf?
        #   @return [Boolean] Whether the user is deafened.
        # @!attribute [r] mute?
        #   @return [Boolean] Whether the user is muted.
        # @!attribute [r] server_deaf?
        #   @return [Boolean] Whether the user is deafened on the server.
        # @!attribute [r] server_mute?
        #   @return [Boolean] Whether the user is muted on the server.
        # @!attribute [r] guild
        #   @macro client_cache
        #   @return [RubyCord::Guild] The guild this voice state is for.
        # @!attribute [r] channel
        #   @macro client_cache
        #   @return [RubyCord::Channel] The channel this voice state is for.
        # @!attribute [r] user
        #   @macro client_cache
        #   @return [RubyCord::User] The user this voice state is for.

        #
        # Initialize a new voice state.
        # @private
        #
        # @param [RubyCord::Client] client The client this voice state belongs to.
        # @param [Hash] data The data of the voice state.
        #
        def initialize(client, data)
          @client = client
          _set_data(data)
        end

        def deaf?
          @deaf || @self_deaf
        end

        def mute?
          @mute || @self_mute
        end

        def server_deaf?
          @deaf
        end

        def server_mute?
          @mute
        end

        def guild
          @guild_id && @client.guilds[@guild_id]
        end

        def channel
          @channel_id && @client.channels[@channel_id]
        end

        def user
          @client.users[@user_id]
        end

        private

        def _set_data(data)
          @data = data
          @guild_id = data[:guild_id]
          @channel_id = data[:channel_id]
          @user_id = data[:user_id]
          unless guild.nil?
            @member =
              if data.key?(:member)
                guild.members[data[:user_id]] ||
                  RubyCord::Guild::Member.new(
                    @client,
                    @guild_id,
                    data[:member][:user],
                    data[:member]
                  )
              else
                guild.members[data[:user_id]]
              end
          end
          @session_id = data[:session_id]
          @deaf = data[:deaf]
          @mute = data[:mute]
          @self_deaf = data[:self_deaf]
          @self_mute = data[:self_mute]
          @self_stream = data[:self_stream]
          @self_video = data[:self_video]
          @suppress = data[:suppress]
          @request_to_speak_timestamp =
            data[:request_to_speak_timestamp] &&
              Time.iso8601(data[:request_to_speak_timestamp])
        end
      end
    end
  end
end
