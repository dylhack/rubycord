module RubyCord
  #
  # Represents a button interaction.
  #
  class Interaction
    class Button < Interaction::Component
      @component_type = 2
      @event_name = :button_click
      # @return [String] The custom id of the button.
      attr_reader :custom_id

      private

      def _set_data(data)
        @custom_id = data[:custom_id]
      end
    end
  end
end
