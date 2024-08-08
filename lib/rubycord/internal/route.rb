module RubyCord::Internal
  #
  # Represents an endpoint.
  # @private
  #
  class Route
    attr_reader :url, :key, :method

    def initialize(url, key, method)
      @url = url
      @key = key
      @method = method
    end

    # @return [String] Object class and attributes.
    def inspect
      "#<#{self.class} #{identifier}>"
    end

    def hash
      @url.hash
    end

    def identifier
      "#{@method} #{@key}"
    end

    def major_param
      param_type = @key.split("/").find { |k| k.start_with?(":") }
      return "" unless param_type

      param =
        url.gsub(API_BASE_URL, "").split("/")[
          @key.split("/").index(param_type) - 1
        ]
      %w[:channel_id :guild_id :webhook_id].include?(param_type) ? param : ""
    end
  end
end
