module RubyCord
  #
  # Represents a client user.
  #
  class Client
    class User < User
      #
      # Edit the client user.
      # @async
      # @macro edit
      #
      # @param [String] name The new username.
      # @param [RubyCord::Image] avatar The new avatar.
      #
      # @return [Async::Task<void>] The task.
      #
      def edit(name: RubyCord::Unset, avatar: RubyCord::Unset)
        Async do
          payload = {}
          payload[:username] = name unless name == RubyCord::Unset
          if avatar == RubyCord::Unset
            # Nothing
          elsif avatar.nil?
            payload[:avatar] = nil
          else
            payload[:avatar] = avatar.to_s
          end
          @client
            .http
            .request(RubyCord::Internal::Route.new("/users/@me", "//users/@me", :patch), payload)
            .wait
          self
        end
      end

      #
      # Represents a user's client status.
      #
      class Status < RubyCord::DiscordModel
        # @return [Symbol] The desktop status of the user.
        attr_reader :desktop
        # @return [Symbol] The mobile status of the user.
        attr_reader :mobile
        # @return [Symbol] The web status of the user.
        attr_reader :web

        # @!attribute [r] desktop?
        #   @return [Boolean] Whether the user is not offline on desktop.
        # @!attribute [r] mobile?
        #   @return [Boolean] Whether the user is not offline on mobile.
        # @!attribute [r] web?
        #   @return [Boolean] Whether the user is not offline on web.

        #
        # Initialize the client status.
        # @private
        #
        # @param [Hash] data The client status data.
        #
        def initialize(data)
          @desktop = data[:desktop]&.to_sym || :offline
          @mobile = data[:mobile]&.to_sym || :offline
          @web = data[:web]&.to_sym || :offline
        end

        def desktop?
          @desktop != :offline
        end

        def mobile?
          @mobile != :offline
        end

        def web?
          @web != :offline
        end
      end
    end
  end
end
