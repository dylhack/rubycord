# frozen_string_literal: true

module RubyCord
  #
  # Represents a channel in guild.
  # @abstract
  #
  class Guild
    class Channel < RubyCord::Channel
      include Comparable
      # @return [Integer] The position of the channel as integer.
      attr_reader :position
      # @return [Hash{RubyCord::Role, RubyCord::Guild::Member => PermissionOverwrite}] The permission overwrites of the channel.
      attr_reader :permission_overwrites

      # @!attribute [r] mention
      #   @return [String] The mention of the channel.
      #
      # @!attribute [r] parent
      #   @macro client_cache
      #   @return [RubyCord::Guild::CategoryChannel] The parent of channel.
      #   @return [nil] If the channel is not a child of category.
      #
      # @!attribute [r] guild
      #   @return [RubyCord::Guild] The guild of channel.
      #   @macro client_cache
      @channel_type = nil

      #
      # Compares position of two channels.
      #
      # @param [RubyCord::Guild::Channel] other The channel to compare.
      #
      # @return [-1, 0, 1] -1 if the channel is at lower than the other, 1 if the channel is at highter than the other.
      #
      def <=>(other)
        return nil unless other.respond_to?(:position)

        @position <=> other.position
      end

      #
      # Checks if the channel is same as another.
      #
      # @param [RubyCord::Guild::Channel] other The channel to check.
      #
      # @return [Boolean] `true` if the channel is same as another.
      #
      def ==(other)
        return false unless other.respond_to?(:id)

        @id == other.id
      end

      #
      # Stringifies the channel.
      #
      # @return [String] The name of the channel with `#`.
      #
      def to_s
        "##{@name}"
      end

      # @return [String] Mentionable string.
      def mention
        "<##{@id}>"
      end

      # @return [RubyCord::Guild::CategoryChannel, nil] The parent of the channel.
      def parent
        return nil unless @parent_id

        @client.channels[@parent_id]
      end

      alias category parent

      # @return [RubyCord::Guild]
      def guild
        @client.guilds[@guild_id]
      end

      # @return [String] Object class and attributes.
      def inspect
        "#<#{self.class} \"##{@name}\" id=#{@id}>"
      end

      #
      # Deletes the channel.
      # @async
      #
      # @param [String] reason The reason of deleting the channel.
      #
      # @return [Async::Task<self>] The deleted channel.
      #
      def delete(reason: nil)
        Async do
          @client
            .http
            .request(
              RubyCord::Internal::Route.new(
                base_url.wait.to_s,
                "//webhooks/:webhook_id/:token",
                :delete
              ),
              {},
              audit_log_reason: reason
            )
            .wait
          @deleted = true
          self
        end
      end

      alias close delete
      alias destroy delete

      #
      # Moves the channel to another position.
      # @async
      #
      # @param [Integer] position The position to move the channel.
      # @param [Boolean] lock_permissions Whether to lock the permissions of the channel.
      # @param [RubyCord::Guild::CategoryChannel] parent The parent of channel.
      # @param [String] reason The reason of moving the channel.
      #
      # @return [Async::Task<self>] The moved channel.
      #
      def move(
        position,
        lock_permissions: false,
        parent: RubyCord::Unset,
        reason: nil
      )
        Async do
          payload = { position: }
          payload[:lock_permissions] = lock_permissions
          payload[:parent_id] = parent&.id if parent != RubyCord::Unset
          @client
            .http
            .request(
              RubyCord::Internal::Route.new(
                "/guilds/#{@guild_id}/channels",
                "//guilds/:guild_id/channels",
                :patch
              ),
              payload,
              audit_log_reason: reason
            )
            .wait
        end
      end

      #
      # Set the channel's permission overwrite.
      # @async
      #
      # @param [RubyCord::Guild::Role, RubyCord::Guild::Member] target The target of the overwrite.
      # @param [String] reason The reason of setting the overwrite.
      # @param [{Symbol => Boolean}] perms The permission overwrites to replace.
      #
      # @return [Async::Task<void>] The task.
      #
      def set_permissions(target, reason: nil, **perms)
        Async do
          allow_value = @permission_overwrites[target]&.allow_value.to_i
          deny_value = @permission_overwrites[target]&.deny_value.to_i
          perms.each do |perm, value|
            allow_value[RubyCord::Permission.bits[perm]] = 1 if value == true
            deny_value[RubyCord::Permission.bits[perm]] = 1 if value == false
          end
          payload = {
            allow: allow_value,
            deny: deny_value,
            type: target.is_a?(Member) ? 1 : 0
          }
          @client
            .http
            .request(
              RubyCord::Internal::Route.new(
                "/channels/#{@id}/permissions/#{target.id}",
                "//channels/:channel_id/permissions/:target_id",
                :put
              ),
              payload,
              audit_log_reason: reason
            )
            .wait
        end
      end

      alias modify_permissions set_permissions
      alias modify_permisssion set_permissions
      alias edit_permissions set_permissions
      alias edit_permission set_permissions

      #
      # Delete the channel's permission overwrite.
      # @async
      #
      # @param [RubyCord::Guild::Role, RubyCord::Guild::Member] target The target of the overwrite.
      # @param [String] reason The reason of deleting the overwrite.
      #
      # @return [Async::Task<void>] The task.
      #
      def delete_permissions(target, reason: nil)
        Async do
          @client
            .http
            .request(
              RubyCord::Internal::Route.new(
                "/channels/#{@id}/permissions/#{target.id}",
                "//channels/:channel_id/permissions/:target_id",
                :delete
              ),
              {},
              audit_log_reason: reason
            )
            .wait
        end
      end

      alias delete_permission delete_permissions
      alias destroy_permissions delete_permissions
      alias destroy_permission delete_permissions

      #
      # Fetch the channel's invites.
      # @async
      #
      # @return [Async::Task<Array<RubyCord::Guild::Invite>>] The invites in the channel.
      #
      def fetch_invites
        Async do
          _resp, data =
            @client
              .http
              .request(
                RubyCord::Internal::Route.new(
                  "/channels/#{@id}/invites",
                  "//channels/:channel_id/invites",
                  :get
                )
              )
              .wait
          data.map { |invite| Guild::Invite.new(@client, invite, false) }
        end
      end

      #
      # Create an invite in the channel.
      # @async
      #
      # @param [Integer] max_age The max age of the invite.
      # @param [Integer] max_uses The max uses of the invite.
      # @param [Boolean] temporary Whether the invite is temporary.
      # @param [Boolean] unique Whether the invite is unique.
      #   @note if it's `false` it may return existing invite.
      # @param [String] reason The reason of creating the invite.
      #
      # @return [Async::Task<Guild::Invite>] The created invite.
      #
      def create_invite(
        max_age: nil,
        max_uses: nil,
        temporary: false,
        unique: false,
        reason: nil
      )
        Async do
          _resp, data =
            @client
              .http
              .request(
                RubyCord::Internal::Route.new(
                  "/channels/#{@id}/invites",
                  "//channels/:channel_id/invites",
                  :post
                ),
                {
                  max_age:,
                  max_uses:,
                  temporary:,
                  unique:
                },
                audit_log_reason: reason
              )
              .wait
          Guild::Invite.new(@client, data, false)
        end
      end

      private

      def _set_data(data)
        @guild_id = data[:guild_id]
        @position = data[:position]
        @permission_overwrites =
          if data[:permission_overwrites]
            data[:permission_overwrites].to_h do |ow|
              [
                (ow[:type] == 1 ? guild.roles : guild.members)[ow[:id]],
                PermissionOverwrite.new(ow[:allow].to_i, ow[:deny].to_i)
              ]
            end
          else
            {}
          end
        @parent_id = data[:parent_id]

        super
      end
    end
  end
end

require_relative "channel/category"
require_relative "channel/stage"
require_relative "channel/text"
require_relative "channel/news"
require_relative "channel/thread"
require_relative "channel/forum"
require_relative "channel/voice"
