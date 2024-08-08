module RubyCord
  #
  # Represents a webhook message.
  #
  class Guild
    class Webhook
      class Message < RubyCord::Message
        # @return [RubyCord::Snowflake] The ID of the channel.
        attr_reader :channel_id
        # @return [RubyCord::Snowflake] The ID of the guild.
        attr_reader :guild_id

        #
        # Initializes the message.
        # @private
        #
        # @param [RubyCord::Guild::Webhook] webhook The webhook.
        # @param [Hash] data The data of the message.
        # @param [RubyCord::Client] client The client. This will be nil if it's created from {URLWebhook}.
        def initialize(webhook, data, client = nil)
          @client = client
          @webhook = webhook
          @data = data
          _set_data(data)
        end

        #
        # Edits the message.
        # @async
        # @macro edit
        #
        # @param (see Webhook#edit_message)
        #
        # @return [Async::Task<void>] The task.
        #
        def edit(...)
          Async { @webhook.edit_message(self, ...).wait }
        end

        #
        # Deletes the message.
        # @async
        #
        # @return [Async::Task<void>] The task.
        #
        def delete
          Async { @webhook.delete_message(self).wait }
        end

        private

        def _set_data(data)
          @id = Snowflake.new(data[:id])
          @type = RubyCord::Message::MESSAGE_TYPE[data[:type]]
          @content = data[:content]
          @channel_id = Snowflake.new(data[:channel_id])
          @author = Author.new(data[:author])
          @attachments = data[:attachments].map { |a| Attachment.new(a) }
          @embeds =
            data[:embeds] ? data[:embeds].map { |e| Embed.from_hash(e) } : []
          @mentions = data[:mentions].map { |m| Mention.new(m) }
          @mention_roles = data[:mention_roles].map { |m| Snowflake.new(m) }
          @mention_everyone = data[:mention_everyone]
          @pinned = data[:pinned]
          @tts = data[:tts]
          @created_at = data[:edited_timestamp] && Time.iso8601(data[:timestamp])
          @updated_at =
            data[:edited_timestamp] && Time.iso8601(data[:edited_timestamp])
          @flags = Message::Flag.new(data[:flags])
          @webhook_id = Snowflake.new(data[:webhook_id])
        end

        #
        # Represents an author of webhook message.
        #
        class Author < RubyCord::DiscordModel
          # @return [Boolean] Whether the author is a bot.
          # @note This will be always `true`.
          attr_reader :bot
          alias bot? bot
          # @return [RubyCord::Snowflake] The ID of the author.
          attr_reader :id
          # @return [String] The name of the author.
          attr_reader :username
          alias name username
          # @return [RubyCord::User::Avatar] The avatar of the author.
          attr_reader :avatar
          # @return [String] The discriminator of the author.
          attr_reader :discriminator

          #
          # Initializes the author.
          # @private
          #
          # @param [Hash] data The data of the author.
          #
          def initialize(data)
            @data = data
            @bot = data[:bot]
            @id = Snowflake.new(data[:id])
            @username = data[:username]
            @avatar = User::Avatar.new(id: @id, discriminator: data[:discriminator], hash: data[:avatar])
            @discriminator = data[:discriminator]
          end

          #
          # Format author with `Name#Discriminator` style.
          #
          # @return [String] Formatted author.
          #
          def to_s
            "#{@username}##{@discriminator}"
          end

          alias to_s_user to_s

          # @return [String] Object class and attributes.
          def inspect
            "#<#{self.class.name} #{self}>"
          end
        end
      end
    end
  end
end
