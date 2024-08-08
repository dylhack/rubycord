
# frozen_string_literal: true

require_relative "../common"

RSpec.describe RubyCord::Internal::ChannelContainer do
  channel_classes = {
    text_channels: RubyCord::Guild::TextChannel,
    voice_channels: RubyCord::Guild::VoiceChannel,
    news_channels: RubyCord::Guild::NewsChannel,
    stage_channels: RubyCord::Guild::StageChannel
  }
  let(:dummy) do
    Class.new do
      include RubyCord::Internal::ChannelContainer

      define_method(:channels) do
        channel_classes
          .values
          .map { |channel_class| [channel_class.allocate] * 2 }
          .flatten
      end
    end
  end

  specify "RubyCord::Guild includes RubyCord::Internal::ChannelContainer" do
    expect(RubyCord::Guild.ancestors).to include(described_class)
  end

  specify "RubyCord::Guild::CategoryChannel includes RubyCord::Internal::ChannelContainer" do
    expect(RubyCord::Guild::CategoryChannel.ancestors).to include(described_class)
  end

  channel_classes.each do |method, channel_class|
    specify "##{method} returns all #{channel_class}s" do
      channels = dummy.new.send(method)
      expect(channels).to all(be_a channel_class)
      expect(channels.length).to eq 2
    end
  end
end
