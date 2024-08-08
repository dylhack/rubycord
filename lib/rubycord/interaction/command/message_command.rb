module RubyCord
  #
  # Represents a message context menu interaction.
  #
  class Interaction
    class MessageCommand < Interaction::Command
      @command_type = 3
      @event_name = :message_command

      # @return [RubyCord::Message] The target message.
      attr_reader :target

      private

      def _set_data(data)
        super
        @target = @messages[data[:target_id]]
        command =
          @client.commands.find do |c|
            c.name["default"] == data[:name] && c.type_raw == 3
          end
        if command
          command.block.call(self, @target)
        else
          @client.logger.warn "Unknown command name #{data[:name]}, ignoring"
        end
      end
    end
  end
end
