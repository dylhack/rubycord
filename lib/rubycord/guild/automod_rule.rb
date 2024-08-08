
# frozen_string_literal: true

module RubyCord
  #
  # Represents a rule of auto moderation.
  #
  class Guild
    class AutoModRule < RubyCord::DiscordModel
      # @return [Hash{Integer => Symbol}] The mapping of trigger types.
      # @private
      TRIGGER_TYPES = {
        1 => :keyword,
        2 => :harmful_link,
        3 => :spam,
        4 => :keyword_preset,
        5 => :mention_spam
      }.freeze
      # @return [Hash{Integer => Symbol}] The mapping of preset types.
      # @private
      PRESET_TYPES = { 1 => :profanity, 2 => :sexual_content, 3 => :slurs }.freeze
      # @return [Hash{Integer => Symbol}] The mapping of event types.
      # @private
      EVENT_TYPES = { 1 => :message_send }.freeze

      # @return [RubyCord::Snowflake] The ID of the rule.
      attr_reader :id
      # @return [String] The name of the rule.
      attr_reader :name
      # @return [Boolean] Whether the rule is enabled.
      attr_reader :enabled
      alias enabled? enabled
      # @return [Array<RubyCord::Guild::AutoModRule::Action>] The actions of the rule.
      attr_reader :actions
      # @return [Array<String>] The keywords that the rule is triggered by.
      # @note This is only available if the trigger type is `:keyword`.
      attr_reader :keyword_filter
      # @return [Array<String>] Substrings which will be exempt from triggering the preset trigger type.
      # @note This is only available if the trigger type is `:keyword_preset`.
      attr_reader :allow_list
      # @return [Integer] Total number of mentions allowed per message.
      # @note This is only available if the trigger type is `:mention_spam`.
      attr_reader :mention_total_limit

      #
      # Initialize a new auto mod.
      # @private
      #
      # @param [RubyCord::Client] client The client.
      # @param [Hash] data The auto mod data.
      #
      def initialize(client, data)
        @client = client
        _set_data(data)
      end

      # @return [Symbol] Returns the type of the preset.
      # @note This is only available if the trigger type is `:keyword_preset`.
      def preset_type
        PRESET_TYPES[@presets_raw]
      end

      # @return [Symbol] Returns the type of the trigger.
      def trigger_type
        TRIGGER_TYPES[@trigger_type_raw]
      end

      # @return [Symbol] Returns the type of the event.
      def event_type
        EVENT_TYPES[@event_type_raw]
      end

      # @return [RubyCord::Guild::Member] The member who created the rule.
      def creator
        guild.members[@creator_id]
      end

      # @return [RubyCord::Guild] The guild that the rule is in.
      def guild
        @client.guilds[@guild_id]
      end

      # @return [Array<RubyCord::Guild::Role>] The roles that the rule is exempt from.
      def exempt_roles
        @exempt_roles_id.map { |id| guild.roles[id] }
      end

      # @return [Array<RubyCord::Channel>] The channels that the rule is exempt from.
      def exempt_channels
        @exempt_channels_id.map { |id| guild.channels[id] }
      end

      #
      # Edit the rule.
      # @async
      #
      # @param [String] name The name of the rule.
      # @param [Symbol] event_type The event type of the rule. See {RubyCord::Guild::AutoModRule::EVENT_TYPES}.
      # @param [Array<RubyCord::Guild::AutoModRule::Action>] actions The actions of the rule.
      # @param [Boolean] enabled Whether the rule is enabled or not.
      # @param [Array<RubyCord::Guild::Role>] exempt_roles The roles that are exempt from the rule.
      # @param [Array<RubyCord::Channel>] exempt_channels The channels that are exempt from the rule.
      # @param [Array<String>] keyword_filter The keywords to filter.
      # @param [Symbol] presets The preset of the rule. See {RubyCord::Guild::AutoModRule::PRESET_TYPES}.
      # @param [String] reason The reason for creating the rule.
      #
      # @return [Async::Task<void>] The task.
      #
      def edit(
        name: RubyCord::Unset,
        event_type: RubyCord::Unset,
        actions: RubyCord::Unset,
        enabled: RubyCord::Unset,
        exempt_roles: RubyCord::Unset,
        exempt_channels: RubyCord::Unset,
        keyword_filter: RubyCord::Unset,
        presets: RubyCord::Unset,
        reason: nil
      )
        payload = { metadata: {} }
        payload[:name] = name unless name == RubyCord::Unset
        payload[:event_type] = EVENT_TYPES.key(event_type) unless event_type ==
          RubyCord::Unset
        payload[:actions] = actions unless actions == RubyCord::Unset
        payload[:enabled] = enabled unless enabled == RubyCord::Unset
        payload[:exempt_roles] = exempt_roles.map(&:id) unless exempt_roles ==
          RubyCord::Unset
        payload[:exempt_channels] = exempt_channels.map(
          &:id
        ) unless exempt_channels == RubyCord::Unset
        payload[:metadata][
          :keyword_filter
        ] = keyword_filter unless keyword_filter == RubyCord::Unset
        payload[:metadata][:presets] = PRESET_TYPES.key(presets) unless presets ==
          RubyCord::Unset

        @client.http.request(
          RubyCord::Internal::Route.new(
            "/guilds/#{@guild_id}/automod/rules/#{@id}",
            "//guilds/:guild_id/automod/rules/:id",
            :patch
          ),
          payload,
          audit_log_reason: reason
        )
      end

      #
      # Delete the rule.
      #
      # @param [String] reason The reason for deleting the rule.
      #
      # @return [Async::Task<void>] The task.
      #
      def delete(reason: nil)
        Async do
          @client.http.request(
            RubyCord::Internal::Route.new(
              "/guilds/#{@guild_id}/automod/rules/#{@id}",
              "//guilds/:guild_id/automod/rules/:id",
              :delete
            ),
            audit_log_reason: reason
          )
        end
      end

      # @private
      def _set_data(data)
        @id = Snowflake.new(data[:id])
        @guild_id = data[:guild_id]
        @name = data[:name]
        @creator_id = data[:creator_id]
        @trigger_type_raw = data[:trigger_type]
        @event_type_raw = data[:event_type]
        @actions =
          data[:actions].map { |action| Action.from_hash(@client, action) }
        case trigger_type
        when :keyword
          @keyword_filter = data[:trigger_metadata][:keyword_filter]
        when :keyword_preset
          @presets_raw = data[:trigger_metadata][:presets]
          @allow_list = data[:trigger_metadata][:allow_list]
        when :mention_spam
          @mention_total_limit = data[:metadata][:mention_total_limit]
        end
        @enabled = data[:enabled]
        @exempt_roles_id = data[:exempt_roles]
        @exempt_channels_id = data[:exempt_channels]
      end

      #
      # Represents the action of auto moderation.
      #
      class Action < RubyCord::DiscordModel
        # @return [Hash{Integer => Symbol}] The mapping of action types.
        # @private
        ACTION_TYPES = {
          1 => :block_message,
          2 => :send_alert_message,
          3 => :timeout
        }.freeze

        # @return [Symbol] Returns the type of the action.
        attr_reader :type
        # @return [Integer] The duration of the timeout.
        # @note This is only available if the action type is `:timeout`.
        attr_reader :duration_seconds

        #
        # Initialize a new action.
        #
        # @param [Symbol] type The type of the action.
        # @param [Integer] duration_seconds The duration of the timeout.
        #   This is only available if the action type is `:timeout`.
        # @param [RubyCord::Channel] channel The channel that the alert message is sent to.
        #   This is only available if the action type is `:send_alert_message`.
        #
        def initialize(type, duration_seconds: nil, channel: nil)
          @type = type
          @duration_seconds = duration_seconds
          @channel = channel
        end

        #
        # Convert the action to hash.
        #
        # @return [Hash] The action hash.
        #
        def to_hash
          {
            type: @type,
            metadata: {
              channel_id: @channel&.id,
              duration_seconds: @duration_seconds
            }
          }
        end

        #
        # Initialize a new action from hash.
        # @private
        #
        # @param [RubyCord::Client] client The client.
        # @param [Hash] data The action data.
        #
        def initialize_hash(client, data)
          @client = client
          _set_data(data)
        end

        # @return [RubyCord::Channel] The channel that the alert message is sent to.
        # @note This is only available if the action type is `:send_alert_message`.
        def channel
          @client.channels[@channel_id]
        end

        # @private
        def _set_data(data)
          @type = ACTION_TYPES[data[:type]]
          @channel_id = data[:metadata][:channel_id]
          @duration_seconds = data[:metadata][:duration_seconds]
        end

        def self.from_hash(client, data)
          allocate.tap { |action| action.initialize_hash(client, data) }
        end
      end
    end
  end
end
