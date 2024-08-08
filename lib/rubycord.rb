
# frozen_string_literal: true

# A new wrapper for the Discorb API.
#
# @author sevenc-nanashi
module RubyCord
  #
  # Method to define a macro for YARD.
  # @private
  #
  # @!macro [new] async
  #   @note This is an asynchronous method, it will return a `Async::Task` object.
  #     Use `Async::Task#wait` to get the result.
  #
  # @!macro [new] client_cache
  #   @note This method returns an object from client cache. it will return `nil` if the object is not in cache.
  #   @return [nil] The object wasn't cached.
  #
  # @!macro members_intent
  #   @note You must enable `GUILD_MEMBERS` intent to use this method.
  #
  # @!macro edit
  #   @note The arguments of this method are defaultly set to `RubyCord::Unset`.
  #     Specify value to set the value, if not don't specify or specify `RubyCord::Unset`.
  #
  # @!macro http
  #   @note This method calls HTTP request.
  #   @raise [RubyCord::HTTPError] HTTP request failed.
  #
  def macro
    puts "Wow, You found the easter egg!\n"
    red = "\e[31m"
    reset = "\e[m"
    puts <<~"EASTEREGG"
                 .               #{red}         #{reset}
               |                 #{red}   |     #{reset}
             __| |  __   __  _   #{red} _ |__    #{reset}
            /  | | (__  /   / \\ #{red}|/  |  \\ #{reset}
            \\__| |  __) \\__ \\_/ #{red}|   |__/  #{reset}

           Thank you for using this library!
         EASTEREGG
  end
end


require "async"
require "async/http"
require "async/websocket"
require "async/barrier"
require "async/websocket/client"
require "json"
require "logger"
require "uri"
require "zlib"

# Common utilities and core functionality
require_relative "rubycord/internal"
require_relative "rubycord/common"
require_relative "rubycord/flag"
require_relative "rubycord/error"

# Message and channel handling
require_relative "rubycord/message_meta"
require_relative "rubycord/allowed_mentions"
require_relative "rubycord/channel"
require_relative "rubycord/message"
require_relative "rubycord/embed"

# User and guild management
require_relative "rubycord/user"
require_relative "rubycord/guild"

# Additional entities and features
require_relative "rubycord/emoji"
require_relative "rubycord/application"
require_relative "rubycord/color"
require_relative "rubycord/component"
require_relative "rubycord/event_handler"

# Attachments and media
require_relative "rubycord/attachment"
require_relative "rubycord/image"
require_relative "rubycord/integration"
require_relative "rubycord/interaction"
require_relative "rubycord/permission"

# Presence and reactions
require_relative "rubycord/reaction"
require_relative "rubycord/sticker"
require_relative "rubycord/utils"

# Gateway and API interaction
require_relative "rubycord/gateway_requests"

require_relative "rubycord/command"

# Infrastructure and client management
require_relative "rubycord/asset"
require_relative "rubycord/extend"
require_relative "rubycord/client"
