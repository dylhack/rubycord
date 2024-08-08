module RubyCord
  #
  # Represents the subcommand group.
  #
  class Command
    class SubCommand < Command::GroupCommand
      # @return [Array<RubyCord::Command::SlashCommand>] The subcommands of the command.
      attr_reader :commands

      #
      # Initialize a new subcommand group.
      # @private
      #
      # @param [String] name The name of the command.
      # @param [String] description The description of the command.
      # @param [RubyCord::Command::GroupCommand] parent The parent command.
      # @param [RubyCord::Client] client The client.
      def initialize(name, description, parent, client)
        super(name, description, [], client, nil, nil)

        @commands = []
        @parent = parent
      end

      def to_s
        "#{@parent} #{@name}"
      end

      #
      # Add new subcommand.
      # @param (see RubyCord::Command::Handler#slash)
      # @return [RubyCord::Command::SlashCommand] The added subcommand.
      #
      def slash(command_name, description, options = {}, &block)
        command =
          RubyCord::Command::SlashCommand.new(
            command_name,
            description,
            options,
            [],
            block,
            1,
            self,
            nil,
            nil
          )
        @commands << command
        @client.callable_commands << command
        command
      end
    end
  end
end
