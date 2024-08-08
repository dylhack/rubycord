# frozen_string_literal: true

module RubyCord
  #
  # Represents a single asset.
  #
  class User::Avatar
    # @return [String, nil] The hash of asset.
    attr_reader :hash

    # @!attribute [r] animated?
    #   @return [Boolean] Whether the asset is animated.

    #
    # Initialize a new instance of the Asset class.
    # @private
    #
    # @param [#to_s] id The ID of the user.
    # @param [String] discriminator The discriminator of the user.
    # @param [String, nil] hash The hash of the asset.
    #
    def initialize(id:, discriminator: 0, hash: nil)
      @hash = hash
      @id = id
      @discriminator = @discriminator.to_s.rjust(4, "0")
    end

    # @return [Boolean] If this user has a default avatar.
    def default?
      @hash.nil?
    end

    # return [Boolean]
    def animated?
      return false if default?

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
      if default?
        "https://cdn.discordapp.com/embed/avatars/#{@discriminator.to_i % 5}.png"
      else
        "https://cdn.discordapp.com/avatars/#{@id}/#{@hash}.#{image_format or (animated? ? "gif" : "webp")}?size=#{size}"
      end
    end

    # @return [String] Object class and attributes.
    def inspect
      "#<#{self.class} #{@target.class} #{@hash}>"
    end
  end
end
