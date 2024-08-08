# typed: true
# frozen_string_literal: true

module RubyCord
  #
  # Represents a message component interaction.
  # @abstract
  #
  class Interaction
    class Component < Interaction
      include Interaction::SourceResponder
      include Interaction::UpdateResponder
      include Interaction::ModalResponder

      # @return [String] The content of the response.
      attr_reader :custom_id
      # @return [RubyCord::Message] The target message.
      attr_reader :message

      @interaction_type = 3
      @interaction_name = :message_component

      #
      # Initialize a new message component interaction.
      # @private
      #
      # @param [RubyCord::Client] client The client.
      # @param [Hash] data The data.
      #
      def initialize(client, data)
        super
        @message =
          Message.new(
            @client,
            data[:message].merge(
              { member: data[:member], guild_id: data[:guild_id] }
            )
          )
      end

      class << self
        # @private
        # @return [Integer] The component type.
        attr_reader :component_type

        #
        # Create a Interaction::Component instance for the given data.
        # @private
        #
        def make_interaction(client, data)
          nested_classes.each do |klass|
            if !klass.component_type.nil? &&
                klass.component_type == data[:data][:component_type]
              return klass.new(client, data)
            end
          end
          client.logger.warn(
            "Unknown component type #{data[:component_type]}, initialized Interaction"
          )
          Interaction::Component.new(client, data)
        end

        #
        # Returns the classes under this class.
        # @private
        #
        def nested_classes
          constants
            .select { |c| const_get(c).is_a? Class }
            .map { |c| const_get(c) }
        end
      end
    end
  end
end

require_relative "component/button"
require_relative "component/select_menu"
