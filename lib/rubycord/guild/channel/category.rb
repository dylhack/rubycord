# frozen_string_literal: true

module RubyCord
  #
  # Represents a category in a guild.
  #
  class Guild
    class CategoryChannel < RubyCord::Guild::Channel
      include RubyCord::Internal::ChannelContainer

      @channel_type = 4

      def channels
        @client.channels.values.filter do |channel|
          channel.parent == self && channel.is_a?(RubyCord::GuildChannel)
        end
      end

      # @param (see RubyCord::Guild#create_text_channel)
      # @see RubyCord::Guild#create_text_channel
      # @return [Async::Task<RubyCord::Guild::TextChannel>] The created text channel.
      def create_text_channel(*args, **kwargs)
        guild.create_text_channel(*args, parent: self, **kwargs)
      end

      # @param (see RubyCord::Guild#create_voice_channel)
      # @see RubyCord::Guild#create_voice_channel
      # @return [Async::Task<RubyCord::Guild::VoiceChannel>] The created voice channel.
      def create_voice_channel(*args, **kwargs)
        guild.create_voice_channel(*args, parent: self, **kwargs)
      end

      # @param (see RubyCord::Guild#create_news_channel)
      # @see RubyCord::Guild#create_news_channel
      # @return [Async::Task<RubyCord::Guild::NewsChannel>] The created news channel.
      def create_news_channel(*args, **kwargs)
        guild.create_news_channel(*args, parent: self, **kwargs)
      end

      # @param (see RubyCord::Guild#create_stage_channel)
      # @see RubyCord::Guild#create_stage_channel
      # @return [Async::Task<RubyCord::Guild::StageChannel>] The created stage channel.
      def create_stage_channel(*args, **kwargs)
        guild.create_stage_channel(*args, parent: self, **kwargs)
      end
    end
  end
end
