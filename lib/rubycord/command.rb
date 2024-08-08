# typed: strict
# frozen_string_literal: true

module RubyCord
  #
  # Represents a application command.
  # @abstract
  #
  class Command < RubyCord::DiscordModel
    # @return [Array<String>] List of valid locales.
    VALID_LOCALES = %w[
      da
      de
      en-GB
      en-US
      es-ES
      fr
      hr
      it
      lt
      hu
      nl
      no
      pl
      pt-BR
      ro
      fi
      sv-SE
      vi
      tr
      cs
      el
      bg
      ru
      uk
      hi
      th
      zh-CN
      ja
      zh-TW
      ko
    ].freeze

    # @return [Hash{String => String}] The name of the command.
    attr_reader :name
    # @return [Array<RubyCord::Snowflake>] The guild ids that the command is enabled in.
    attr_reader :guild_ids
    # @return [Proc] The block of the command.
    attr_reader :block
    # @return [:chat_input, :user, :message] The type of the command.
    attr_reader :type
    # @return [Integer] The raw type of the command.
    attr_reader :type_raw
    # @return [RubyCord::Permission] The default permissions for this command.
    attr_reader :default_permission
    # @return [Boolean] Whether the command is enabled in DMs.
    attr_reader :dm_permission

    # @private
    # @return [{Integer => Symbol}] The mapping of raw types to types.
    TYPES = { 1 => :chat_input, 2 => :user, 3 => :message }.freeze

    #
    # Initialize a new command.
    # @private
    #
    # @param [String, Hash{Symbol => String}] name The name of the command.
    # @param [Array<#to_s>, false, nil] guild_ids The guild ids that the command is enabled in.
    # @param [Proc] block The block of the command.
    # @param [Integer] type The type of the command.
    # @param [Boolean] dm_permission Whether the command is enabled in DMs.
    # @param [RubyCord::Permission] default_permission The default permission of the command.
    #
    def initialize(
      name,
      guild_ids,
      block,
      type,
      dm_permission = true,
      default_permission = nil
    )
      @name =
        (
          if name.is_a?(String)
            { "default" => name }
          else
            Command.modify_localization_hash(name)
          end
        )
      @guild_ids = guild_ids&.map { |id| Snowflake.new(id) }
      @block = block
      @type = RubyCord::Command::TYPES[type]
      @type_raw = type
      @dm_permission = dm_permission
      @default_permission = default_permission
    end

    #
    # Changes the self pointer of block to the given object.
    # @private
    #
    # @param [Object] instance The object to change the self pointer to.
    #
    def replace_block(instance)
      current_block = @block.dup
      @block = proc { |*args| instance.instance_exec(*args, &current_block) }
    end

    #
    # Converts the object to a hash.
    # @private
    #
    # @return [Hash] The hash represents the object.
    #
    def to_hash
      {
        name: @name["default"],
        name_localizations: @name.except("default"),
        type: @type_raw,
        dm_permission: @dm_permission,
        default_member_permissions: @default_permission&.value&.to_s
      }
    end

    def self.modify_localization_hash(hash)
      hash.to_h do |rkey, value|
        key = rkey.to_s.gsub("_", "-")
        if VALID_LOCALES.none? { |valid| valid.downcase == key.downcase } &&
            key != "default"
          raise ArgumentError, "Invalid locale: #{key}"
        end

        [
          (
            if key == "default"
              "default"
            else
              VALID_LOCALES.find { |valid| valid.downcase == key.downcase }
            end
          ),
          value
        ]
      end
      end
  end
end

require_relative "command/slash_command"
require_relative "command/group_command"
require_relative "command/sub_command"
