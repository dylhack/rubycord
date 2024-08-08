
module RubyCord
  class Client
    module Gateway
      require_relative "gateway/event"
      require_relative "gateway/shard"
      require_relative "gateway/intents"
    end
  end
end
