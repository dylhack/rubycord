# frozen_string_literal: true

require_relative "../common"

RSpec.describe RubyCord::Client::Gateway::Intents do
  RubyCord::Client::Gateway::Intents::INTENT_BITS.each do |key, value|
    specify "##{key} is associated with #{value}" do
      expect(described_class.from_value(value)).to(
        satisfy { |intent| intent.send(key) }
      )
    end

    specify "value of .new with `#{key}: true` is #{value}" do
      intent = described_class.none
      intent.send("#{key}=", true)
      expect(intent.value).to eq(value)
    end
  end
end
