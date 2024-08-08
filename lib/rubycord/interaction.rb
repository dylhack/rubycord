# frozen_string_literal: true

module RubyCord
  #
  # Represents a user interaction with the bot.
  #
  class Interaction < RubyCord::DiscordModel
    # @return [RubyCord::Snowflake] The ID of the interaction.
    attr_reader :id
    # @return [RubyCord::Snowflake] The ID of the application that created the interaction.
    attr_reader :application_id
    # @return [Symbol] The type of interaction.
    attr_reader :type
    # @return [RubyCord::User, RubyCord::Guild::Member] The user or member that created the interaction.
    attr_reader :user
    alias member user
    # @return [Integer] The type of interaction.
    # @note This is always `1` for now.
    attr_reader :version
    # @return [String] The token for the interaction.
    attr_reader :token
    # @return [Symbol] The locale of the user that created the interaction.
    # @note This modifies the language code, `-` will be replaced with `_`.
    attr_reader :locale
    # @return [Symbol] The locale of the guild that created the interaction.
    # @note This modifies the language code, `-` will be replaced with `_`.
    attr_reader :guild_locale
    # @return [RubyCord::Permission] The permissions of the bot.
    attr_reader :app_permissions

    # @!attribute [r] guild
    #   @macro client_cache
    #   @return [RubyCord::Guild] The guild the interaction took place in.
    # @!attribute [r] channel
    #   @macro client_cache
    #   @return [RubyCord::Channel] The channel the interaction took place in.
    # @!attribute [r] target
    #   @return [RubyCord::User, RubyCord::Guild::Member] The user or member the interaction took place with.

    @interaction_type = nil
    @interaction_name = nil

    #
    # Initialize a new interaction.
    # @private
    #
    # @param [RubyCord::Client] client The client this interaction belongs to.
    # @param [Hash] data The data of the interaction.
    #
    def initialize(client, data)
      @client = client
      @id = Snowflake.new(data[:id])
      @application_id = Snowflake.new(data[:application_id])
      @type = self.class.interaction_name
      @type_id = self.class.interaction_type
      @guild_id = data[:guild_id] && Snowflake.new(data[:guild_id])
      @channel_id = data[:channel_id] && Snowflake.new(data[:channel_id])
      if data[:member]
        @user =
          guild.members[data[:member][:id]] ||
            RubyCord::Guild::Member.new(@client, @guild_id, data[:member][:user], data[:member])
      elsif data[:user]
        @user =
          @client.users[data[:user][:id]] || User.new(@client, data[:user])
      end
      @token = data[:token]
      @locale = data[:locale].to_s.gsub("-", "_").to_sym
      @guild_locale = data[:guild_locale].to_s.gsub("-", "_").to_sym
      @app_permissions =
        data[:app_permissions] && Permission.new(data[:app_permissions].to_i)
      @version = data[:version]
      @defered = false
      @responded = false
      _set_data(data[:data])
    end

    # @return [RubyCord::Guild]
    def guild
      @client.guilds[@guild_id]
    end

    # @return [RubyCord::Channel]
    def channel
      @client.channels[@channel_id]
    end

    # @return [String] Object class and attributes.
    def inspect
      "#<#{self.class} id=#{@id}>"
    end

    #
    # Send followup message.
    #
    # @async
    #
    # @param [String] content The content of the response.
    # @param [Boolean] tts Whether to send the message as text-to-speech.
    # @param [RubyCord::Embed] embed The embed to send.
    # @param [Array<RubyCord::Embed>] embeds The embeds to send. (max: 10)
    # @param [RubyCord::AllowedMentions] allowed_mentions The allowed mentions to send.
    # @param [RubyCord::Attachment] attachment The attachment to send.
    # @param [Array<RubyCord::Attachment>] attachments The attachments to send. (max: 10)
    # @param [Array<RubyCord::Component>, Array<Array<RubyCord::Component>>] components The components to send.
    # @param [Boolean] ephemeral Whether to make the response ephemeral.
    #
    # @return [RubyCord::Guild::Webhook::Message] The message.
    #
    def post(
      content = nil,
      tts: false,
      embed: nil,
      embeds: nil,
      allowed_mentions: nil,
      attachment: nil,
      attachments: nil,
      components: nil,
      ephemeral: false
    )
      Async do
        payload = {}
        payload[:content] = content if content
        payload[:tts] = tts
        payload[:embeds] = (embeds || [embed])
          .map { |e| e&.to_hash }
          .filter { _1 }
        payload[:allowed_mentions] = allowed_mentions&.to_hash(
          @client.allowed_mentions
        ) || @client.allowed_mentions.to_hash
        payload[:components] = Component.to_payload(components) if components
        payload[:flags] = (ephemeral ? 1 << 6 : 0)
        attachments ||= attachment ? [attachment] : []

        payload[:attachments] = attachments.map.with_index do |a, i|
          { id: i, filename: a.filename, description: a.description }
        end

        _resp, data =
          @client
            .http
            .multipart_request(
              RubyCord::Internal::Route.new(
                "/webhooks/#{@application_id}/#{@token}",
                "//webhooks/:webhook_id/:token",
                :post
              ),
              payload,
              attachments
            )
            .wait
        webhook =
          Guild::Webhook::URLWebhook.new("/webhooks/#{@application_id}/#{@token}")
        Guild::Webhook::Message.new(webhook, data, @client)
        ret
      end
    end

    #
    # Edit the original response message.
    # This method is low-level.
    #
    # @async
    #
    # @param [String] content The content of the response.
    # @param [RubyCord::Embed] embed The embed to send.
    # @param [Array<RubyCord::Embed>] embeds The embeds to send. (max: 10)
    # @param [Array<RubyCord::Attachment>] attachments The attachments to send. (max: 10)
    # @param [Array<RubyCord::Component>, Array<Array<RubyCord::Component>>] components The components to send.
    #
    # @return [Async::Task<void>] The task.
    #
    # @see CallbackMessage#edit
    #
    def edit_original_message(
      content = nil,
      embed: nil,
      embeds: nil,
      attachments: nil,
      components: nil
    )
      Async do
        payload = {}
        payload[:content] = content if content
        payload[:embeds] = (embeds || [embed])
          .map { |e| e&.to_hash }
          .filter { _1 }
          .then { _1.empty? ? nil : _1 }
        payload[:components] = Component.to_payload(components) if components

        payload[:attachments] = attachments.map.with_index do |a, i|
          { id: i, filename: a.filename, description: a.description }
        end if attachments
        payload.compact!

        @client
          .http
          .multipart_request(
            RubyCord::Internal::Route.new(
              "/webhooks/#{@application_id}/#{@token}/messages/@original",
              "//webhooks/:webhook_id/:token/messages/@original",
              :patch
            ),
            payload,
            attachments
          )
          .wait
      end
    end

    #
    # Delete the original response message.
    # This method is low-level.
    #
    # @async
    #
    # @return [Async::Task<void>] The task.
    #
    def delete_original_message
      Async do
        @client
          .http
          .request(
            RubyCord::Internal::Route.new(
              "/webhooks/#{@application_id}/#{@token}/messages/@original",
              "//webhooks/:webhook_id/:token/messages/@original",
              :delete
            )
          )
          .wait
      end
    end

    class << self
      # @private
      attr_reader :interaction_type, :interaction_name, :event_name

      #
      # Create a new Interaction instance from the data.
      # @private
      #
      # @param [RubyCord::Client] client The client this interaction belongs to.
      # @param [Hash] data The data of the interaction.
      #
      def make_interaction(client, data)
        interaction = nil
        descendants.each do |klass|
          if !klass.interaction_type.nil? &&
               klass.interaction_type == data[:type]
            interaction = klass.make_interaction(client, data)
          end
        end
        if interaction.nil?
          client.logger.warn(
            "Unknown interaction type #{data[:type]}, initialized Interaction"
          )
          interaction = Interaction.new(client, data)
        end
        interaction
      end

      #
      # Returns the descendants of the class.
      # @private
      #
      def descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end
    end
  end
end

require_relative "interaction/response"
require_relative "interaction/command"
require_relative "interaction/components"
require_relative "interaction/autocomplete"
require_relative "interaction/modal"
