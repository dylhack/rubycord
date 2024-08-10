# frozen_string_literal: true

module RubyCord
  #
  # Represents a button component.
  #
  class Component
    class Button < Component
      # @return [String] The label of the button.
      attr_accessor :label
      # @return [:primary, :secondary, :success, :danger, :link] The style of the button.
      attr_accessor :style
      # @return [RubyCord::Emoji] The emoji of the button.
      attr_accessor :emoji
      # @return [String] The custom ID of the button.
      #   Won't be used if the style is `:link`.
      attr_accessor :custom_id
      # @return [String] The URL of the button.
      #   Only used when the style is `:link`.
      attr_accessor :url
      # @return [Boolean] Whether the button is disabled.
      attr_accessor :disabled
      alias disabled? disabled

      # @private
      # @return [{Symbol => Integer}] The mapping of button styles.
      STYLES = { primary: 1, secondary: 2, success: 3, danger: 4, link: 5 }.freeze

      #
      # Initialize a new button.
      #
      # @param [String] label The label of the button.
      # @param [:primary, :secondary, :success, :danger, :link] style The style of the button.
      # @param [RubyCord::Emoji] emoji The emoji of the button.
      # @param [String] custom_id The custom ID of the button.
      # @param [String] url The URL of the button.
      # @param [Boolean] disabled Whether the button is disabled.
      #
      def initialize(
        label,
        style = :primary,
        emoji: nil,
        custom_id: nil,
        url: nil,
        disabled: false
      )
        @label = label
        @style = style
        @emoji = emoji
        @custom_id = custom_id
        @url = url
        @disabled = disabled
      end

      #
      # Converts the button to a hash.
      #
      # @see https://discord.com/developers/docs/interactions/message-components#button-object-button-structure
      #  Official Discord API docs
      # @return [Hash] A hash representation of the button.
      #
      def to_hash
        if @style == :link
          {
            type: 2,
            label: @label,
            style: STYLES[@style],
            url: @url,
            emoji: @emoji&.to_hash,
            disabled: @disabled
          }
        else
          {
            type: 2,
            label: @label,
            style: STYLES[@style],
            custom_id: @custom_id,
            emoji: @emoji&.to_hash,
            disabled: @disabled
          }
        end
      end

      # @return [String] Object class and attributes.
      def inspect
        "#<#{self.class}: #{@custom_id || @url}>"
      end

      class << self
        #
        # Creates a new button from a hash.
        #
        # @param [Hash] data The hash to create the button from.
        #
        # @return [RubyCord::Component::Button] The created button.
        #
        def from_hash(data)
          new(
            data[:label],
            data[:style],
            emoji: data[:emoji],
            custom_id: data[:custom_id],
            url: data[:url],
            disabled: data[:disabled]
          )
        end
      end
    end
  end
end
