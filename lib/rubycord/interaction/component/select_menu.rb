module RubyCord
  #
  # Represents a select menu interaction.
  #
  class Interaction
    class SelectMenu < Interaction::Component
      @component_type = 3
      @event_name = :select_menu_select
      # @return [String] The custom id of the select menu.
      attr_reader :custom_id
      # @return [Array<String>] The selected options.
      attr_reader :values

      # @!attribute [r] value
      #   @return [String] The first selected value.

      def value
        @values[0]
      end

      private

      def _set_data(data)
        @custom_id = data[:custom_id]
        @values = data[:values]
      end
    end
  end
end
