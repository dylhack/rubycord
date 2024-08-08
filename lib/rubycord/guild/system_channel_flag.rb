# frozen_string_literal: true

module RubyCord
  #
  # Represents a system channel flag.
  # ## Flag fields
  # |Field|Value|
  # |-|-|
  # |`1 << 0`|`:member_join`|
  # |`1 << 1`|`:server_boost`|
  # |`1 << 2`|`:setup_tips`|
  # |`1 << 3`|`:join_stickers`|
  #
  class Guild
    class SystemChannelFlag < RubyCord::Flag
      @bits = {
        member_join: 0,
        server_boost: 1,
        setup_tips: 2,
        join_stickers: 3
      }.freeze
    end
  end
end
