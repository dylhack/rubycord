module RubyCord
  #
  # Represents the command with subcommands.
  #
  class Command
    class GroupCommand < Command
      # @return [Array<RubyCord::Command>] The subcommands of the command.
      attr_reader :commands
      # @return [Hash{String => String}] The description of the command.
      attr_reader :description

      #
      # Initialize a new group command.
      # @private
      #
      # @param [String, Hash{Symbol => String}] name The name of the command.
      # @param [String, Hash{Symbol => String}] description The description of the command.
      # @param [Array<#to_s>] guild_ids The guild ids that the command is enabled in.
      # @param [RubyCord::Client] client The client of the command.
      # @param [Boolean] dm_permission Whether the command is enabled in DMs.
      # @param [RubyCord::Permission] default_permission The default permission of the command.
      #
      def initialize(
        name,
        description,
        guild_ids,
        client,
        dm_permission,
        default_permission
      )
        super(name, guild_ids, block, 1, dm_permission, default_permission)
        @description =
          if description.is_a?(String)
            { "default" => description }
          else
            Command.modify_localization_hash(description)
          end
        @commands = []
        @client = client
      end

      #
      # Add new subcommand.
      #
      # @param (see RubyCord::Command::Handler#slash)
      # @return [RubyCord::Command::SlashCommand] The added subcommand.
      #
      def slash(
        command_name,
        description,
        options = {},
        dm_permission: true,
        default_permission: nil,
        &block
      )
        command =
          RubyCord::Command::SlashCommand.new(
            command_name,
            description,
            options,
            [],
            block,
            1,
            self,
            dm_permission,
            default_permission
          )
        @client.callable_commands << command
        @commands << command
        command
      end

      #
      # Add new subcommand group.
      #
      # @param [String] command_name Group name.
      # @param [String] description Group description.
      #
      # @yield Block to yield with the command.
      # @yieldparam [RubyCord::Command::SubCommand] group Group command.
      #
      # @return [RubyCord::Command::SubCommand] Command object.
      #
      def group(command_name, description)
        command =
          RubyCord::Command::SubCommand.new(
            command_name,
            description,
            self,
            @client
          )
        yield command if block_given?
        @commands << command
        command
      end

      #
      # Returns the command name.
      #
      # @return [String] The command name.
      #
      def to_s
        @name["default"]
      end

      #
      # Changes the self pointer to the given object.
      # @private
      #
      # @param [Object] instance The object to change to.
      #
      def block_replace(instance)
        super
        @commands.each { |c| c.replace_block(instance) }
      end

      #
      # Converts the object to a hash.
      # @private
      #
      # @return [Hash] The hash represents the object.
      #
      def to_hash
        options_payload =
          @commands.map do |command|
            if command.is_a?(RubyCord::Command::SlashCommand)
              {
                name: command.name["default"],
                name_localizations: command.name.except("default"),
                description: command.description["default"],
                description_localizations:
                  command.description.except("default"),
                type: 1,
                options: command.to_hash[:options]
              }
            else
              {
                name: command.name["default"],
                name_localizations: command.name.except("default"),
                description: command.description["default"],
                description_localizations:
                  command.description.except("default"),
                type: 2,
                options:
                  command.commands.map do |c|
                    c
                      .to_hash
                      .merge(type: 1)
                      .except(:dm_permission, :default_member_permissions)
                  end
              }
            end
          end

        {
          name: @name["default"],
          name_localizations: @name.except("default"),
          description: @description["default"],
          description_localizations: @description.except("default"),
          dm_permission: @dm_permission,
          default_member_permissions: @default_permission&.value&.to_s,
          options: options_payload
        }
      end
    end
  end
end
