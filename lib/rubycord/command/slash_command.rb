module RubyCord
  #
  # Represents the slash command.
  #
  class Command
    class SlashCommand < Command
      # @return [Hash{String => String}] The description of the command.
      attr_reader :description
      # @return [Hash{String => Hash}] The options of the command.
      attr_reader :options

      #
      # Initialize a new slash command.
      # @private
      #
      # @param [String, Hash{Symbol => String}] name The name of the command.
      #   The hash should have `default`, and language keys.
      # @param [String, Hash{Symbol => String}] description The description of the command.
      #   The hash should have `default`, and language keys.
      # @param [Hash{String => Hash}] options The options of the command.
      # @param [Array<#to_s>] guild_ids The guild ids that the command is enabled in.
      # @param [Proc] block The block of the command.
      # @param [Integer] type The type of the command.
      # @param [RubyCord::Command, nil] parent The parent command.
      # @param [Boolean] dm_permission Whether the command is enabled in DMs.
      # @param [RubyCord::Permission] default_permission The default permission of the command.
      #
      def initialize(
        name,
        description,
        options,
        guild_ids,
        block,
        type,
        parent,
        dm_permission,
        default_permission
      )
        super(name, guild_ids, block, type, dm_permission, default_permission)
        @description =
          if description.is_a?(String)
            { "default" => description }
          else
            Command.modify_localization_hash(description)
          end
        @options = options
        @parent = parent
      end

      #
      # Returns the commands name.
      #
      # @return [String] The name of the command.
      #
      def to_s
        "#{@parent} #{@name["default"]}".strip
      end

      #
      # Converts the object to a hash.
      # @private
      #
      # @return [Hash] The hash represents the object.
      #
      def to_hash
        options_payload =
          options.map do |name, value|
            ret = {
              type:
                case value[:type]
                when String, :string, :str
                  3
                when Integer, :integer, :int
                  4
                when TrueClass, FalseClass, :boolean, :bool
                  5
                when RubyCord::User, RubyCord::Guild::Member, :user, :member
                  6
                when RubyCord::Channel, :channel
                  7
                when RubyCord::Guild::Role, :role
                  8
                when :mentionable
                  9
                when Float, :float
                  10
                when :attachment
                  11
                else
                  raise ArgumentError, "Invalid option type: #{value[:type]}"
                end,
              name:,
              name_localizations:
                Command.modify_localization_hash(
                  value[:name_localizations]
                ),
              required:
                value[:required].nil? ? !value[:optional] : value[:required]
            }

            if value[:description].is_a?(String)
              ret[:description] = value[:description]
            else
              description =
                Command.modify_localization_hash(
                  value[:description]
                )
              ret[:description] = description["default"]
              ret[:description_localizations] = description.except("default")
            end
            if value[:choices]
              ret[:choices] = value[:choices].map do |k, v|
                r = { name: k, value: v }
                if choices_localizations = value[:choices_localizations].clone
                  name_localizations =
                    Command.modify_localization_hash(
                      choices_localizations.delete(k) do
                        warn "Missing localization for #{k}"
                        {}
                      end
                    )
                  r[:name_localizations] = name_localizations.except(
                    "default"
                  )
                  r[:name] = name_localizations["default"]
                  r.delete(:name_localizations) if r[:name_localizations].nil?
                end
                r
              end
            end

            ret[:channel_types] = value[:channel_types].map(
              &:channel_type
            ) if value[:channel_types]

            ret[:autocomplete] = !value[:autocomplete].nil? if value[
              :autocomplete
            ]
            if value[:range]
              ret[:min_value] = value[:range].begin
              ret[:max_value] = value[:range].end
            end
            if value[:length]
              ret[:min_length] = value[:length].begin
              ret[:max_length] = value[:length].end
            end
            ret
          end
        {
          name: @name["default"],
          name_localizations: @name.except("default"),
          description: @description["default"],
          description_localizations: @description.except("default"),
          options: options_payload,
          dm_permission: @dm_permission,
          default_member_permissions: @default_permission&.value&.to_s
        }
      end
    end
  end
end
