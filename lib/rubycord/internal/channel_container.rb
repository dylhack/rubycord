# frozen_string_literal: true

#
# Module for container of channels.
#
module RubyCord::Internal::ChannelContainer
  #
  # Returns text channels.
  #
  # @return [Array<RubyCord::Guild::TextChannel>] The text channels.
  #
  def text_channels
    channels.filter { |c| c.instance_of? RubyCord::Guild::TextChannel }
  end

  #
  # Returns voice channels.
  #
  # @return [Array<RubyCord::Guild::VoiceChannel>] The voice channels.
  #
  def voice_channels
    channels.filter { |c| c.instance_of? RubyCord::Guild::VoiceChannel }
  end

  #
  # Returns news channels.
  #
  # @return [Array<RubyCord::Guild::NewsChannel>] The news channels.
  #
  def news_channels
    channels.filter { |c| c.instance_of? RubyCord::Guild::NewsChannel }
  end

  #
  # Returns stage channels.
  #
  # @return [Array<RubyCord::Guild::StageChannel>] The stage channels.
  #
  def stage_channels
    channels.filter { |c| c.instance_of? RubyCord::Guild::StageChannel }
  end
end
