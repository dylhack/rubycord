module RubyCord
  #
  # Represents a slash command interaction.
  #
  class Interaction
    class SlashCommand < Interaction::Command
      @command_type = 1
      @event_name = :slash_command

      private

      def _set_data(data)
        super

        name, options = SlashCommand.get_command_data(data)

        unless (
                  command =
                    @client.callable_commands.find do |c|
                      c.to_s == name && c.type_raw == 1
                    end
                )
          @client.logger.warn "Unknown command name #{name}, ignoring"
          return
        end

        option_map = command.options.to_h { |k, v| [k.to_s, v[:default]] }
        SlashCommand.modify_option_map(
          option_map,
          options,
          guild,
          @members,
          @attachments
        )

        command.block.call(
          self,
          *command.options.map { |k, _v| option_map[k.to_s] }
        )
      end

      class << self
        #
        # Get command data from the given data.
        # @private
        #
        # @param [Hash] data The data of the command.
        #
        def get_command_data(data)
          name = data[:name]
          options = nil
          return name, options unless (option = data[:options]&.first)

          case option[:type]
          when 1
            name += " #{option[:name]}"
            options = option[:options]
          when 2
            name += " #{option[:name]}"
            unless option[:options]&.first&.[](:type) == 1
              options = option[:options]
              return name, options
            end
            option_sub = option[:options]&.first
            name += " #{option_sub[:name]}"
            options = option_sub[:options]
          else
            options = data[:options]
          end

          [name, options]
        end

        #
        # Modify the option map with the given options.
        # @private
        #
        # @param [Hash] option_map The option map to modify.
        # @param [Array<Hash>] options The options for modifying.
        # @param [RubyCord::Guild] guild The guild where the command is executed.
        # @param [{RubyCord::Snowflake => RubyCord::Guild::Member}] members The cached members of the guild.
        # @param [{Integer => RubyCord::Attachment}] attachments The cached attachments of the message.
        def modify_option_map(option_map, options, guild, members, attachments)
          options ||= []
          options.each do |option|
            val =
              case option[:type]
              when 3, 4, 5, 10
                option[:value]
              when 6
                members[option[:value]] ||
                  (
                    guild &&
                      (
                        guild.members[option[:value]] ||
                          guild.fetch_member(option[:value]).wait
                      )
                  )
              when 7
                if guild
                  guild.channels[option[:value]] ||
                    guild.fetch_channels.wait.find do |channel|
                      channel.id == option[:value]
                    end
                end
              when 8
                guild &&
                  (
                    guild.roles[option[:value]] ||
                      guild.fetch_roles.wait.find do |role|
                        role.id == option[:value]
                      end
                  )
              when 9
                members[option[:value]] ||
                  (
                    guild &&
                      (
                        guild.members[option[:value]] ||
                          guild.roles[option[:value]] ||
                          guild.fetch_member(option[:value]).wait ||
                          guild.fetch_roles.wait.find do |role|
                            role.id == option[:value]
                          end
                      )
                  )
              when 11
                attachments[option[:value]]
              end
            option_map[option[:name]] = val
          end
        end
      end
    end
  end
end
