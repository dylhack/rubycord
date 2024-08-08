
# frozen_string_literal: true

module RubyCord
  #
  # A module for response with source.
  #
  class Interaction
    module SourceResponder
      #
      # Response with `DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE`(`5`).
      #
      # @async
      #
      # @param [Boolean] ephemeral Whether to make the response ephemeral.
      #
      # @return [Async::Task<void>] The task.
      #
      def defer_source(ephemeral: false)
        Async do
          @client
            .http
            .request(
              RubyCord::Internal::Route.new(
                "/interactions/#{@id}/#{@token}/callback",
                "//interactions/:interaction_id/:token/callback",
                :post
              ),
              { type: 5, data: { flags: (ephemeral ? 1 << 6 : 0) } }
            )
            .wait
          @defered = true
        end
      end

      #
      # Response with `CHANNEL_MESSAGE_WITH_SOURCE`(`4`).
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
      # @return [RubyCord::Interaction::SourceResponder::CallbackMessage, RubyCord::Webhook::Message]
      #   The callback message.
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

          ret =
            if @responded
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
                Guild::Webhook::URLWebhook.new(
                  "/webhooks/#{@application_id}/#{@token}"
                )
              Guild::Webhook::Message.new(webhook, data, @client)
            elsif @defered
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
              CallbackMessage.new(@client, payload, @application_id, @token)
            else
              @client
                .http
                .multipart_request(
                  RubyCord::Internal::Route.new(
                    "/interactions/#{@id}/#{@token}/callback",
                    "//interactions/:interaction_id/:token/callback",
                    :post
                  ),
                  { type: 4, data: payload },
                  attachments
                )
                .wait
              CallbackMessage.new(@client, payload, @application_id, @token)
            end
          @responded = true
          ret
        end
      end
    end

    #
    # Represents of a callback message of interaction.
    #
    class CallbackMessage
      #
      # Initializes a new instance of CallbackMessage.
      # @private
      #
      # @param [Client] client The client.
      # @param [Hash] data The payload.
      # @param [String] application_id The application ID.
      # @param [String] token The token.
      #
      def initialize(client, data, application_id, token)
        @client = client
        @data = data
        @application_id = application_id
        @token = token
      end

      #
      # Edits the callback message.
      # @async
      # @macro edit
      #
      # @param [String] content The new content of the message.
      # @param [RubyCord::Embed] embed The new embed of the message.
      # @param [Array<RubyCord::Embed>] embeds The new embeds of the message.
      # @param [Array<RubyCord::Attachment>] attachments The attachments to remain.
      # @param [RubyCord::Attachment] file The file to send.
      # @param [Array<RubyCord::Attachment>] files The files to send.
      #
      # @return [Async::Task<void>] The task.
      #
      def edit(
        content = RubyCord::Unset,
        embed: RubyCord::Unset,
        embeds: RubyCord::Unset,
        file: RubyCord::Unset,
        files: RubyCord::Unset,
        attachments: RubyCord::Unset
      )
        Async do
          payload = {}
          payload[:content] = content if content != RubyCord::Unset
          payload[:embeds] = embed ? [embed.to_hash] : [] if embed !=
            RubyCord::Unset
          payload[:embeds] = embeds.map(&:to_hash) if embeds != RubyCord::Unset
          payload[:attachments] = attachments.map(&:to_hash) if attachments !=
            RubyCord::Unset
          files = [file] if file != RubyCord::Unset
          files = [] if files == RubyCord::Unset
          @client
            .http
            .multipart_request(
              RubyCord::Internal::Route.new(
                "/webhooks/#{@application_id}/#{@token}/messages/@original",
                "//webhooks/:webhook_id/:token/messages/@original",
                :patch
              ),
              payload,
              files
            )
            .wait
        end
      end

      alias modify edit

      #
      # Deletes the callback message.
      # @async
      # @note This will fail if the message is ephemeral.
      #
      # @return [Async::Task<void>] The task.
      #
      def delete
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

      def inspect
        "#<#{self.class.name} application_id=#{@application_id}"
      end
    end

    #
    # A module for response with update.
    #
    module Interaction::UpdateResponder
      #
      # Response with `DEFERRED_UPDATE_MESSAGE`(`6`).
      # @async
      #
      # @param [Boolean] ephemeral Whether to make the response ephemeral.
      #
      # @return [Async::Task<void>] The task.
      #
      def defer_update(ephemeral: false)
        Async do
          @client
            .http
            .request(
              RubyCord::Internal::Route.new(
                "/interactions/#{@id}/#{@token}/callback",
                "//interactions/:interaction_id/:token/callback",
                :post
              ),
              { type: 6, data: { flags: (ephemeral ? 1 << 6 : 0) } }
            )
            .wait
        end
      end

      #
      # Response with `UPDATE_MESSAGE`(`7`).
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
      # @return [Async::Task<void>] The task.
      #
      def edit(
        content,
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
          tmp_embed =
            if embed
              [embed]
            elsif embeds
              embeds
            end
          payload[:embeds] = tmp_embed.map(&:to_hash) if tmp_embed
          payload[:allowed_mentions] = (
            if allowed_mentions
              allowed_mentions.to_hash(@client.allowed_mentions)
            else
              @client.allowed_mentions.to_hash
            end
          )
          payload[:components] = Component.to_payload(components) if components
          payload[:flags] = (ephemeral ? 1 << 6 : 0)
          attachments ||= [attachment] if attachment
          payload[:attachments] = attachments.map.with_index do |a, i|
            { id: i, filename: a.filename, description: a.description }
          end
          @client
            .http
            .multipart_request(
              RubyCord::Internal::Route.new(
                "/interactions/#{@id}/#{@token}/callback",
                "//interactions/:interaction_id/:token/callback",
                :post
              ),
              { type: 7, data: payload },
              attachments
            )
            .wait
        end
      end
    end

    #
    # A module for response with modal.
    #
    module Interaction::ModalResponder
      #
      # Response with `MODAL`(`9`).
      #
      # @param [String] title The title of the modal.
      # @param [String] custom_id The custom id of the modal.
      # @param [Array<RubyCord::Component::TextInput>] components The text inputs to send.
      #
      # @return [Async::Task<void>] The task.
      #
      def show_modal(title, custom_id, components)
        Async do
          payload = {
            title:,
            custom_id:,
            components: Component.to_payload(components)
          }
          @client
            .http
            .request(
              RubyCord::Internal::Route.new(
                "/interactions/#{@id}/#{@token}/callback",
                "//interactions/:interaction_id/:token/callback",
                :post
              ),
              { type: 9, data: payload }
            )
            .wait
        end
      end
    end

    private

    def _set_data(_)
      nil
    end
  end
end
