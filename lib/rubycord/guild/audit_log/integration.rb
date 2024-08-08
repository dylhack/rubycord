module RubyCord
  #
  # Represents an integration in an audit log entry.
  #
  class Guild
    class AuditLog
      class Integration < RubyCord::DiscordModel
        # @return [RubyCord::Snowflake] The ID of the integration.
        attr_reader :id
        # @return [Symbol] The type of the integration.
        attr_reader :type
        # @return [String] The name of the integration.
        attr_reader :name
        # @return [RubyCord::Integration::Account] The account of the integration.
        attr_reader :account

        #
        # Initializes a new integration object.
        # @private
        #
        def initialize(data)
          @id = Snowflake.new(data[:id])
          @type = data[:type].to_sym
          @name = data[:name]
          @data = data
          @account = RubyCord::Integration::Account.new(@data[:account]) if @data[
            :account
          ]
        end

        def inspect
          "#<#{self.class} #{@id}>"
        end
      end
    end
  end
end
