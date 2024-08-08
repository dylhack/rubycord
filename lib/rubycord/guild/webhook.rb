# frozen_string_literal: true

module RubyCord
  #
  # Represents a webhook.
  # @abstract
  #
  class Guild
    class Webhook
      # @return [String] The name of the webhook.
      attr_reader :name
      # @return [RubyCord::Snowflake] The ID of the guild this webhook belongs to.
      attr_reader :guild_id
      # @return [RubyCord::Snowflake] The ID of the channel this webhook belongs to.
      attr_reader :channel_id
      # @return [RubyCord::User] The user that created this webhook.
      attr_reader :user
      # @return [RubyCord::Asset] The avatar of the webhook.
      attr_reader :avatar
      # @return [RubyCord::Snowflake] The application ID of the webhook.
      # @return [nil] If the webhook is not an application webhook.
      attr_reader :application_id
      # @return [String] The URL of the webhook.
      attr_reader :token

      #
      # Initializes a webhook.
      # @private
      #
      # @param [RubyCord::Client] client The client.
      # @param [Hash] data The data of the webhook.
      #
      def initialize(client, data)
        @name = data[:name]
        @guild_id = data[:guild_id] && Snowflake.new(data[:guild_id])
        @channel_id = Snowflake.new(data[:channel_id])
        @id = Snowflake.new(data[:id])
        @user = data[:user]
        @name = data[:name]
        @avatar = User::Avatar.new(id: @id, hash: data[:avatar])
        @token = ""
        @application_id = data[:application_id]
        @client = client
        @http = RubyCord::Client::HTTP.new(client)
      end

      def inspect
        "#<#{self.class} #{@name.inspect} id=#{@id}>"
      end

      #
      # Posts a message to the webhook.
      # @async
      #
      # @param [String] content The content of the message.
      # @param [Boolean] tts Whether the message should be sent as text-to-speech.
      # @param [RubyCord::Embed] embed The embed to send.
      # @param [Array<RubyCord::Embed>] embeds The embeds to send.
      # @param [RubyCord::AllowedMentions] allowed_mentions The allowed mentions to send.
      # @param [Array<RubyCord::Attachment>] attachments The attachments to send.
      # @param [String] username The username of the message.
      # @param [String] avatar_url The avatar URL of the message.
      # @param [Boolean] wait Whether to wait for the message to be sent.
      #
      # @return [RubyCord::Guild::Webhook::Message] The message that was sent.
      # @return [Async::Task<nil>] If `wait` is false.
      #
      def post(
        content = nil,
        tts: false,
        embed: nil,
        embeds: nil,
        allowed_mentions: nil,
        attachments: nil,
        username: nil,
        avatar_url: RubyCord::Unset,
        wait: true
      )
        Async do
          payload = {}
          payload[:content] = content if content
          payload[:tts] = tts
          tmp_embed =
            if embed
              [embed]
            elsif embeds
              embeds
            end
          payload[:embeds] = tmp_embed.map(&:to_hash) if tmp_embed
          payload[:allowed_mentions] = allowed_mentions&.to_hash
          payload[:username] = username if username
          payload[:avatar_url] = avatar_url if avatar_url != RubyCord::Unset
          _resp, data =
            @http.multipart_request(
              RubyCord::Internal::Route.new(
                "#{url}?wait=#{wait}",
                "//webhooks/:webhook_id/:token",
                :post
              ),
              payload,
              attachments
            ).wait
          data && Guild::Webhook::Message.new(self, data)
        end
      end

      alias execute post

      #
      # Edits the webhook.
      # @async
      # @macro edit
      #
      # @param [String] name The new name of the webhook.
      # @param [RubyCord::Image] avatar The new avatar of the webhook.
      # @param [RubyCord::Guild::Channel] channel The new channel of the webhook.
      #
      # @return [Async::Task<void>] The task.
      #
      def edit(
        name: RubyCord::Unset,
        avatar: RubyCord::Unset,
        channel: RubyCord::Unset
      )
        Async do
          payload = {}
          payload[:name] = name if name != RubyCord::Unset
          payload[:avatar] = avatar if avatar != RubyCord::Unset
          payload[:channel_id] = Utils.try(channel, :id) if channel !=
            RubyCord::Unset
          @http.request(
            RubyCord::Internal::Route.new(url, "//webhooks/:webhook_id/:token", :patch),
            payload
          ).wait
        end
      end

      alias modify edit

      #
      # Deletes the webhook.
      # @async
      #
      # @return [Async::Task<void>] The task.
      #
      def delete
        Async do
          @http.request(
            RubyCord::Internal::Route.new(url, "//webhooks/:webhook_id/:token", :delete)
          ).wait
          self
        end
      end

      alias destroy delete

      #
      # Edits the webhook's message.
      # @async
      # @macro edit
      #
      # @param [RubyCord::Guild::Webhook::Message] message The message to edit.
      # @param [String] content The new content of the message.
      # @param [RubyCord::Embed] embed The new embed of the message.
      # @param [Array<RubyCord::Embed>] embeds The new embeds of the message.
      # @param [Array<RubyCord::Attachment>] attachments The attachments to remain.
      # @param [RubyCord::Attachment] file The file to send.
      # @param [Array<RubyCord::Attachment>] files The files to send.
      # @param [RubyCord::AllowedMentions] allowed_mentions The allowed mentions to send.
      #
      # @return [Async::Task<void>] The task.
      #
      def edit_message(
        message,
        content = RubyCord::Unset,
        embed: RubyCord::Unset,
        embeds: RubyCord::Unset,
        file: RubyCord::Unset,
        files: RubyCord::Unset,
        attachments: RubyCord::Unset,
        allowed_mentions: RubyCord::Unset
      )
        Async do
          payload = {}
          payload[:content] = content if content != RubyCord::Unset
          payload[:embeds] = embed ? [embed.to_hash] : [] if embed !=
            RubyCord::Unset
          payload[:embeds] = embeds.map(&:to_hash) if embeds != RubyCord::Unset
          payload[:attachments] = attachments.map(&:to_hash) if attachments !=
            RubyCord::Unset
          payload[:allowed_mentions] = allowed_mentions if allowed_mentions !=
            RubyCord::Unset
          files = [file] if file != RubyCord::Unset
          _resp, data =
            @http.multipart_request(
              RubyCord::Internal::Route.new(
                "#{url}/messages/#{Utils.try(message, :id)}",
                "//webhooks/:webhook_id/:token/messages/:message_id",
                :patch
              ),
              payload,
              files
            ).wait
          message.send(:_set_data, data)
          message
        end
      end

      #
      # Deletes the webhook's message.
      #
      # @param [RubyCord::Guild::Webhook::Message] message The message to delete.
      #
      # @return [Async::Task<void>] The task.
      #
      def delete_message(message)
        Async do
          @http.request(
            RubyCord::Internal::Route.new(
              "#{url}/messages/#{Utils.try(message, :id)}",
              "//webhooks/:webhook_id/:token/messages/:message_id",
              :delete
            )
          ).wait
          message
        end
      end

      class << self
        #
        # Creates Webhook with discord data.
        # @private
        #
        # @param [RubyCord::Client] client The client.
        # @param [Hash] data The data of the webhook.
        #
        # @return [RubyCord::Guild::Webhook] The Webhook.
        #
        def from_data(client, data)
          case data[:type]
          when 1
            Guild::IncomingWebhook
          when 2
            Guild::FollowerWebhook
          when 3
            Guild::ApplicationWebhook
          end.new(client, data)
        end

        def from_url(url)
          URLWebhook.new(url)
        end
      end
    end
  end
end

require_relative "webhook/application_webhook"
require_relative "webhook/follower_webhook"
require_relative "webhook/incoming_webhook"
require_relative "webhook/message"
require_relative "webhook/url_webhook"
