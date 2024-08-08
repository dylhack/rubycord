# typed: true
# frozen_string_literal: true

module RubyCord
  #
  # Represents a command interaction.
  #
  class Interaction
    class Command < Interaction
      include Interaction::SourceResponder
      include Interaction::ModalResponder

      @interaction_type = 2
      @interaction_name = :application_command

      private

      def _set_data(data)
        super
        @name = data[:name]
        @messages = {}
        @attachments = {}
        @members = {}

        if data[:resolved]
          data[:resolved][:users]&.each do |id, user|
            @client.users[id] = RubyCord::User.new(@client, user)
          end
          data[:resolved][:members]&.each do |id, member|
            @members[id] = RubyCord::Guild::Member.new(
              @client,
              @guild_id,
              data[:resolved][:users][id],
              member
            )
          end

          data[:resolved][:messages]&.each do |id, message|
            @messages[id.to_s] = Message.new(
              @client,
              message.merge(guild_id: @guild_id.to_s)
            )
          end
          data[:resolved][:attachments]&.each do |id, attachment|
            @attachments[id.to_s] = Attachment.new(attachment)
          end
        end
      end

      class << self
        # @private
        attr_reader :command_type, :event_name

        #
        # Creates a new Interaction::Command instance for the given data.
        # @private
        #
        # @param [RubyCord::Client] client The client.
        # @param [Hash] data The data for the command.
        #
        def make_interaction(client, data)
          nested_classes.each do |klass|
            unless !klass.command_type.nil? &&
                    klass.command_type == data[:data][:type]
              next
            end
            interaction = klass.new(client, data)
            client.dispatch(klass.event_name, interaction)
            return interaction
          end
          client.logger.warn(
            "Unknown command type #{data[:type]}, initialized Interaction::Command"
          )
          Interaction::Command.new(client, data)
        end

        #
        # Returns the classes under this class.
        # @private
        #
        def nested_classes
          constants
            .select { |c| const_get(c).is_a? Class }
            .map { |c| const_get(c) }
        end
      end
    end
  end
end

require_relative "command/message_command"
require_relative "command/user_command"
require_relative "command/slash_command"
