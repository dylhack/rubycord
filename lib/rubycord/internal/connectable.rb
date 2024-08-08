#
# Module for connecting to a voice channel.
# This will be discord-voice gem.
#
module RubyCord::Internal::Connectable
  def connect
    raise NotImplementedError,
          "This method is implemented by discord-voice gem."
  end
end
