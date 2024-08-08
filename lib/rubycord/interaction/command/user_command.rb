module RubyCord
  #
  # Represents a user context menu interaction.
  #
  class Interaction
      class UserCommand < Interaction::Command
      @command_type = 2
      @event_name = :user_command

      # @return [RubyCord::Guild::Member, RubyCord::User] The target user.
      attr_reader :target

      private

      def _set_data(data)
        super
        @target =
          guild.members[data[:target_id]] ||
            RubyCord::Guild::Member.new(
              @client,
              @guild_id,
              data[:resolved][:users][data[:target_id].to_sym],
              data[:resolved][:members][data[:target_id].to_sym]
            )
        command =
          @client.commands.find do |c|
            c.name["default"] == data[:name] && c.type_raw == 2
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
