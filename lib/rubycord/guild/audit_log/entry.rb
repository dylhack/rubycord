
module RubyCord
  #
  # Represents an entry in an audit log.
  #
  class Guild
    class AuditLog
      class Entry < RubyCord::DiscordModel
        # @return [RubyCord::Snowflake] The ID of the entry.
        attr_reader :id
        # @return [RubyCord::Snowflake] The ID of the user who performed the action.
        attr_reader :user_id
        # @return [RubyCord::Snowflake] The ID of the target of the action.
        attr_reader :target_id
        # @return [Symbol] The type of the entry.
        # These symbols will be used:
        #
        # * `:guild_update`
        # * `:channel_create`
        # * `:channel_update`
        # * `:channel_delete`
        # * `:channel_overwrite_create`
        # * `:channel_overwrite_update`
        # * `:channel_overwrite_delete`
        # * `:member_kick`
        # * `:member_prune`
        # * `:member_ban_add`
        # * `:member_ban_remove`
        # * `:member_update`
        # * `:member_role_update`
        # * `:member_move`
        # * `:member_disconnect`
        # * `:bot_add`
        # * `:role_create`
        # * `:role_update`
        # * `:role_delete`
        # * `:invite_create`
        # * `:invite_update`
        # * `:invite_delete`
        # * `:webhook_create`
        # * `:webhook_update`
        # * `:webhook_delete`
        # * `:emoji_create`
        # * `:emoji_update`
        # * `:emoji_delete`
        # * `:message_delete`
        # * `:message_bulk_delete`
        # * `:message_pin`
        # * `:message_unpin`
        # * `:integration_create`
        # * `:integration_update`
        # * `:integration_delete`
        # * `:stage_instance_create`
        # * `:stage_instance_update`
        # * `:stage_instance_delete`
        # * `:sticker_create`
        # * `:sticker_update`
        # * `:sticker_delete`
        # * `:guild_scheduled_event_create`
        # * `:guild_scheduled_event_update`
        # * `:guild_scheduled_event_delete`
        # * `:thread_create`
        # * `:thread_update`
        # * `:thread_delete`
        # * `:application_command_permission_update``
        attr_reader :type
        # @return [RubyCord::Guild::AuditLog::Entry::Changes] The changes in this entry.
        attr_reader :changes
        # @return [RubyCord::Channel, RubyCord::Guild::Role, RubyCord::Guild::Member, RubyCord::Guild, RubyCord::Message, Snowflake]
        #   The target of the entry.
        attr_reader :target
        # @return [Hash{Symbol => Object}] The optional data for this entry.
        # @note You can use dot notation to access the data.
        attr_reader :options

        # @!attribute [r] user
        #   @return [RubyCord::User] The user who performed the action.

        #
        # @return [{Integer => Symbol}] The map of events to their respective changes.
        # @private
        #
        EVENTS = {
          1 => :guild_update,
          10 => :channel_create,
          11 => :channel_update,
          12 => :channel_delete,
          13 => :channel_overwrite_create,
          14 => :channel_overwrite_update,
          15 => :channel_overwrite_delete,
          20 => :member_kick,
          21 => :member_prune,
          22 => :member_ban_add,
          23 => :member_ban_remove,
          24 => :member_update,
          25 => :member_role_update,
          26 => :member_move,
          27 => :member_disconnect,
          28 => :bot_add,
          30 => :role_create,
          31 => :role_update,
          32 => :role_delete,
          40 => :invite_create,
          41 => :invite_update,
          42 => :invite_delete,
          50 => :webhook_create,
          51 => :webhook_update,
          52 => :webhook_delete,
          60 => :emoji_create,
          61 => :emoji_update,
          62 => :emoji_delete,
          72 => :message_delete,
          73 => :message_bulk_delete,
          74 => :message_pin,
          75 => :message_unpin,
          80 => :integration_create,
          81 => :integration_update,
          82 => :integration_delete,
          83 => :stage_instance_create,
          84 => :stage_instance_update,
          85 => :stage_instance_delete,
          90 => :sticker_create,
          91 => :sticker_update,
          92 => :sticker_delete,
          100 => :guild_scheduled_event_create,
          101 => :guild_scheduled_event_update,
          102 => :guild_scheduled_event_delete,
          110 => :thread_create,
          111 => :thread_update,
          112 => :thread_delete,
          121 => :application_command_permission_update,
          140 => :automod_rule_create,
          141 => :automod_rule_update,
          142 => :automod_rule_delete,
          143 => :automod_block_message
        }.freeze

        #
        # The converter for the change.
        # @private
        #
        CONVERTERS = {
          channel: ->(client, id, _guild_id) { client.channels[id] },
          thread: ->(client, id, _guild_id) { client.channels[id] },
          role: ->(client, id, guild_id) do
            client.guilds[guild_id]&.roles&.[](id)
          end,
          member: ->(client, id, guild_id) do
            client.guilds[guild_id]&.members&.[](id)
          end,
          guild: ->(client, id, _guild_id) { client.guilds[id] },
          message: ->(client, id, _guild_id) { client.messages[id] }
        }.freeze

        #
        # Initializes a new Guild::AuditLog entry.
        # @private
        #
        def initialize(client, data, guild_id)
          @client = client
          @guild_id = Snowflake.new(guild_id)
          @id = Snowflake.new(data[:id])
          @user_id = Snowflake.new(data[:user_id])
          @target_id = Snowflake.new(data[:target_id])
          @type = EVENTS[data[:action_type]] || :unknown
          @target =
            CONVERTERS[@type.to_s.split("_")[0].to_sym]&.call(
              client,
              @target_id,
              @gui
            )
          @target ||= Snowflake.new(data[:target_id])
          @changes = data[:changes] && Changes.new(data[:changes])
          @reason = data[:reason]
          data[:options]&.each do |option, value|
            define_singleton_method(option) { value }
            next unless option.end_with?("_id") &&
                  CONVERTERS.key?(option.to_s.split("_")[0].to_sym)
            define_singleton_method(option.to_s.sub("_id", "")) do
              CONVERTERS[option.to_s.split("_")[0].to_sym]&.call(
                client,
                value,
                @guild_id
              )
            end
          end
          @options = data[:options] || {}
        end

        def user
          @client.users[@user_id]
        end

        #
        # Get a change with the given key.
        #
        # @param [Symbol] key The key to get.
        #
        # @return [RubyCord::Guild::AuditLog::Entry::Change] The change with the given key.
        # @return [nil] The change with the given key does not exist.
        #
        def [](key)
          @changes[key]
        end

        def inspect
          "#<#{self.class} #{@changes&.data&.length || "No"} changes>"
        end

        class << self
          attr_reader :events, :converts
        end

        #
        # Represents the changes in an audit log entry.
        #
        class Changes < RubyCord::DiscordModel
          attr_reader :data

          #
          # Initializes a new changes object.
          # @private
          #
          # @param [Hash] data The data to initialize with.
          #
          def initialize(data)
            @data = data.to_h { |d| [d[:key].to_sym, d] }
            @data.each { |k, v| define_singleton_method(k) { Change.new(v) } }
          end

          #
          # @return [String] Formats the changes into a string.
          #
          def inspect
            "#<#{self.class} #{@data.length} changes>"
          end

          #
          # Get keys of changes.
          #
          # @return [Array<Symbol>] The keys of the changes.
          #
          def keys
            @data.keys
          end

          #
          # Get a change with the given key.
          #
          # @param [Symbol] key The key to get.
          #
          # @return [RubyCord::Guild::AuditLog::Entry::Change] The change with the given key.
          # @return [nil] The change with the given key does not exist.
          #
          def [](key)
            @data[key.to_sym]
          end
        end

        #
        # Represents a change in an audit log entry.
        # @note This instance will try to call a method of {#new_value} if the method wasn't defined.
        #
        class Change < RubyCord::DiscordModel
          # @return [Symbol] The key of the change.
          attr_reader :key
          # @return [Object] The old value of the change.
          attr_reader :old_value
          # @return [Object] The new value of the change.
          attr_reader :new_value

          #
          # Initializes a new change object.
          # @private
          #
          def initialize(data)
            @key = data[:key].to_sym
            method =
              case @key.to_s
              when /.*_id$/, "id"
                ->(v) { Snowflake.new(v) }
              when "permissions"
                ->(v) { RubyCord::Permission.new(v.to_i) }
              when "status"
                ->(v) { RubyCord::Guild::Event::STATUS[v] }
              when "entity_type"
                ->(v) { RubyCord::Guild::Event::ENTITY_TYPE[v] }
              when "privacy_level"
                ->(v) do
                  RubyCord::Guild::StageChannel::StageInstance::PRIVACY_LEVEL[v] ||
                    RubyCord::Guild::Event::PRIVACY_LEVEL[v]
                end
              else
                ->(v) { v }
              end
            @old_value = method.call(data[:old_value])
            @new_value = method.call(data[:new_value])
          end

          #
          # Send a message to the new value.
          #
          def method_missing(method, ...)
            @new_value.__send__(method, ...)
          end

          #
          # Format the change into a string.
          #
          # @return [String] The string representation of the change.
          #
          def inspect
            "#<#{self.class} #{@key.inspect} #{@old_value.inspect} -> #{@new_value.inspect}>"
          end

          #
          # Whether the change responds to the given method.
          #
          # @return [Boolean] Whether the change responds to the given method.
          #
          def respond_to_missing?(method, include_private = false)
            @new_value.respond_to?(method, include_private)
          end
        end
      end
    end
  end
end
