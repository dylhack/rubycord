# frozen_string_literal: true

module RubyCord
  #
  # Represents a stage instance of a voice state.
  #
  class Guild
    class StageChannel
      class StageInstance < RubyCord::DiscordModel
        # @return [RubyCord::Snowflake] The ID of the guild this voice state is for.
        attr_reader :id
        # @return [String] The topic of the stage instance.
        attr_reader :topic
        # @return [:public, :guild_only] The privacy level of the stage instance.
        attr_reader :privacy_level

        # @!attribute [r] guild
        #   @macro client_cache
        #   @return [RubyCord::Guild] The guild this voice state is for.
        # @!attribute [r] channel
        #   @macro client_cache
        #   @return [RubyCord::Channel] The channel this voice state is for.
        # @!attribute [r] discoverable?
        #   @return [Boolean] Whether the stage instance is discoverable.
        # @!attribute [r] public?
        #   @return [Boolean] Whether the stage instance is public.
        # @!attribute [r] guild_only?
        #   @return [Boolean] Whether the stage instance is guild-only.

        @privacy_level = { 1 => :public, 2 => :guild_only }

        #
        # Initialize a new instance of the StageInstance class.
        # @private
        #
        # @param [RubyCord::Client] client The client.
        # @param [Hash] data The data of the stage instance.
        # @param [Boolean] no_cache Whether to disable caching.
        #
        def initialize(client, data, no_cache: false)
          @client = client
          @data = data
          _set_data(data)
          channel.stage_instances[@id] = self unless no_cache
        end

        def guild
          @client.guilds[@data[:guild_id]]
        end

        def channel
          @client.channels[@data[:channel_id]]
        end

        def discoverable?
          !@discoverable_disabled
        end

        def public?
          @privacy_level == :public
        end

        def guild_only?
          @privacy_level == :guild_only
        end

        def inspect
          "#<#{self.class} topic=#{@topic.inspect}>"
        end

        #
        # Edits the stage instance.
        # @async
        # @macro edit
        #
        # @param [String] topic The new topic of the stage instance.
        # @param [:public, :guild_only] privacy_level The new privacy level of the stage instance.
        # @param [String] reason The reason for editing the stage instance.
        #
        # @return [Async::Task<void>] The task.
        #
        def edit(topic: RubyCord::Unset, privacy_level: RubyCord::Unset, reason: nil)
          Async do
            payload = {}
            payload[:topic] = topic if topic != RubyCord::Unset
            payload[:privacy_level] = PRIVACY_LEVEL.key(
              privacy_level
            ) if privacy_level != RubyCord::Unset
            @client
              .http
              .request(
                RubyCord::Internal::Route.new(
                  "/stage-instances/#{@channel_id}",
                  "//stage-instances/:channel_id",
                  :patch
                ),
                payload,
                audit_log_reason: reason
              )
              .wait
            self
          end
        end

        alias modify edit

        #
        # Deletes the stage instance.
        #
        # @param [String] reason The reason for deleting the stage instance.
        #
        # @return [Async::Task<void>] The task.
        #
        def delete(reason: nil)
          Async do
            @client
              .http
              .request(
                RubyCord::Internal::Route.new(
                  "/stage-instances/#{@channel_id}",
                  "//stage-instances/:stage_instance_id",
                  :delete
                ),
                {},
                audit_log_reason: reason
              )
              .wait
            self
          end
        end

        alias destroy delete
        alias end delete

        private

        def _set_data(data)
          @id = Snowflake.new(data[:id])
          @guild_id = Snowflake.new(data[:guild_id])
          @channel_id = Snowflake.new(data[:channel_id])
          @topic = data[:topic]
          @privacy_level = PRIVACY_LEVEL[data[:privacy_level]]
          @discoverable_disabled = data[:discoverable_disabled]
        end

        class << self
          attr_reader :privacy_level
        end
      end
    end
  end
end
