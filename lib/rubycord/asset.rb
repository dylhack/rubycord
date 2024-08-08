# frozen_string_literal: true

module RubyCord
  #
  # Represents a single asset.
  #
  class Asset < RubyCord::DiscordModel
    # @return [String] The hash of asset.
    attr_reader :hash

    # @!attribute [r] animated?
    #   @return [Boolean] Whether the asset is animated.

    #
    # Initialize a new instance of the Asset class.
    # @private
    #
    # @param [User, Guild, Guild::Member, Guild::Webhook, Application, Application::Team, Integration::Application] target The target of the asset.
    # @param [String] hash The hash of the asset.
    # @param [String] path The path of the asset.
    #
    def initialize(target, hash, path: nil)
      @hash = hash
      @target = target
      @path = path
    end

    # return [Boolean]
    def animated?
      @hash.start_with? "a_"
    end

    #
    # URL of the asset.
    #
    # @param [String] image_format The image format.
    # @param [Integer] size The size of the image.
    #
    # @return [String] URL of the asset.
    #
    def url(image_format: nil, size: 1024)
      path = @path || "#{endpoint}/#{@target.id}"
      "https://cdn.discordapp.com/#{path}/#{@hash}.#{image_format or (animated? ? "gif" : "webp")}?size=#{size}"
    end

    # @return [String] Object class and attributes.
    def inspect
      "#<#{self.class} #{@target.class} #{@hash}>"
    end

    private

    def endpoint
      case @target
      when User, Guild::Member, Guild::Webhook
        "avatars"
      when Guild, Guild::Webhook::FollowerWebhook::Guild
        "icons"
      when Application, Integration::Application
        "app-icons"
      when Application::Team
        "team-icons"
      end
    end
  end

  #
  # Represents a default avatar.
  #
  class DefaultAvatar < RubyCord::DiscordModel
    # @!attribute [r] animated?
    #   @return [false] For compatibility with {Asset}, always `false`.

    #
    # Initialize a new instance of the DefaultAvatar class.
    # @private
    #
    def initialize(discriminator)
      @discriminator = discriminator.to_s.rjust(4, "0")
    end

    # @return [false]
    def animated?
      false
    end

    #
    # Returns the URL of the avatar.
    #
    # @param [String] image_format The image format. This is compatible with {Asset#url}, will be ignored.
    # @param [Integer] size The size of the image. This is compatible with {Asset#url}, will be ignored.
    #
    # @return [String] URL of the avatar.
    #
    # rubocop: disable Lint/UnusedMethodArgument
    def url(image_format: nil, size: 1024)
      # rubocop: enable Lint/UnusedMethodArgument
      "https://cdn.discordapp.com/embed/avatars/#{@discriminator.to_i % 5}.png"
    end

    # @return [String] Object class and attributes.
    def inspect
      "#<#{self.class} #{@discriminator}>"
    end
  end
end
