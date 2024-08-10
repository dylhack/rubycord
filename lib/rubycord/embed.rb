# typed: true
# frozen_string_literal: true

module RubyCord
  #
  # Represents an embed of discord.
  #
  class Embed
    # @return [String, nil] The title of embed.
    attr_accessor :title
    # @return [String, nil] The description of embed.
    attr_accessor :description
    # @return [String, nil] The url of embed.
    attr_accessor :url
    # @return [Time, nil] The timestamp of embed.
    attr_accessor :timestamp
    # @return [RubyCord::Color, nil] The color of embed.
    attr_accessor :color
    # @return [RubyCord::Embed::Author, nil] The author of embed.
    attr_accessor :author
    # @return [Array<RubyCord::Embed::Field>] The fields of embed.
    attr_accessor :fields
    # @return [RubyCord::Embed::Footer, nil] The footer of embed.
    attr_accessor :footer
    # @return [Symbol] The type of embed.
    attr_reader :type
    attr_reader :image, :thumbnail

    # @!attribute [rw] image
    #   @return [RubyCord::Embed::Image] The image of embed.
    # @!attribute [rw] thumbnail
    #   @return [RubyCord::Embed::Thumbnail] The thumbnail of embed.

    #
    # Initialize a new Embed object.
    #
    # @param [String] title The title of embed.
    # @param [String] description The description of embed.
    # @param [RubyCord::Color, Integer] color The color of embed.
    # @param [String] url The url of embed.
    # @param [Time] timestamp The timestamp of embed.
    # @param [RubyCord::Embed::Author] author The author field of embed.
    # @param [Array<RubyCord::Embed::Field>] fields The fields of embed.
    # @param [RubyCord::Embed::Footer] footer The footer of embed.
    # @param [RubyCord::Embed::Image, String] image The image of embed.
    # @param [RubyCord::Embed::Thumbnail, String] thumbnail The thumbnail of embed.
    #
    def initialize(
      title = nil,
      description = nil,
      color: nil,
      url: nil,
      timestamp: nil,
      author: nil,
      fields: nil,
      footer: nil,
      image: nil,
      thumbnail: nil
    )
      @title = title
      @description = description
      @url = url
      @timestamp = timestamp
      @color = color && (color.is_a?(Color) ? color : Color.new(color))
      @author = author
      @fields = fields || []
      @footer = footer
      @image = image && (image.is_a?(String) ? Image.new(image) : image)
      @thumbnail =
        thumbnail &&
          (thumbnail.is_a?(String) ? Thumbnail.new(thumbnail) : thumbnail)
      @type = :rich
    end

    #
    # Initialize embed from hash.
    # @private
    #
    # @param [Hash] data The hash data to initialize embed.
    #
    def initialize_hash(data)
      @title = data[:title]
      @description = data[:description]
      @url = data[:url]
      @timestamp = data[:timestamp] && Time.iso8601(data[:timestamp])
      @type = data[:type]
      @color = data[:color] && Color.new(data[:color])
      @footer =
        data[:footer] &&
          Footer.new(data[:footer][:text], icon: data[:footer][:icon_url])
      @author =
        if data[:author]
          Author.new(
            data[:author][:name],
            icon: data[:author][:icon_url],
            url: data[:author][:url]
          )
        end
      @thumbnail = data[:thumbnail] && Thumbnail.new(data[:thumbnail])
      @image = data[:image] && Image.new(data[:image])
      @video = data[:video] && Video.new(data[:video])
      @provider = data[:provider] && Provider.new(data[:provider])
      @fields =
        (
          if data[:fields]
            data[:fields].map do |f|
              Field.new(f[:name], f[:value], inline: f[:inline])
            end
          else
            []
          end
        )
    end

    def image=(value)
      @image = value.is_a?(String) ? Image.new(value) : value
    end

    def thumbnail=(value)
      @thumbnail = value.is_a?(String) ? Thumbnail.new(value) : value
    end

    def inspect
      "#<#{self.class} \"#{@title}\">"
    end

    #
    # Convert embed to hash.
    #
    # @see https://discord.com/developers/docs/resources/channel#embed-object-embed-structure Offical Discord API Docs
    # @return [Hash] Converted embed.
    #
    def to_hash
      ret = { type: "rich" }
      ret[:title] = @title if @title
      ret[:description] = @description if @description
      ret[:url] = @url if @url
      ret[:timestamp] = @timestamp&.iso8601 if @timestamp
      ret[:color] = @color&.to_i if @color
      ret[:footer] = @footer&.to_hash if @footer
      ret[:image] = @image&.to_hash if @image
      ret[:thumbnail] = @thumbnail&.to_hash if @thumbnail
      ret[:author] = @author&.to_hash if @author
      ret[:fields] = @fields&.map(&:to_hash) if @fields.any?
      ret
    end

    def self.from_hash(data)
      inst = allocate
      inst.initialize_hash(data)
      inst
    end

    #
    # Represents an entry in embed.
    # @abstract
    # @private
    #
    class Entry
      def inspect
        "#<#{self.class}>"
      end
    end

    #
    # Represents an author of embed.
    #
    class Author < Entry
      # @return [String] The name of author.
      attr_accessor :name
      # @return [String, nil] The url of author.
      attr_accessor :url
      # @return [String, nil] The icon url of author.
      attr_accessor :icon

      #
      # Initialize a new Author object.
      #
      # @param [String] name The name of author.
      # @param [String] url The url of author.
      # @param [String] icon The icon url of author.
      #
      def initialize(name, url: nil, icon: nil)
        @name = name
        @url = url
        @icon = icon
      end

      #
      # Convert author to hash.
      #
      # @see https://discord.com/developers/docs/resources/channel#embed-object-embed-author-structure
      #   Offical Discord API Docs
      # @return [Hash] Converted author.
      #
      def to_hash
        { name: @name, url: @url, icon_url: @icon }
      end
    end

    #
    # Represemts a footer of embed.
    #
    class Footer < Entry
      attr_accessor :text, :icon

      #
      # Initialize a new Footer object.
      #
      # @param [String] text The text of footer.
      # @param [String] icon The icon url of footer.
      #
      def initialize(text, icon: nil)
        @text = text
        @icon = icon
      end

      #
      # Convert footer to hash.
      #
      # @see https://discord.com/developers/docs/resources/channel#embed-object-embed-footer-structure
      #   Offical Discord API Docs
      # @return [Hash] Converted footer.
      #
      def to_hash
        { text: @text, icon_url: @icon }
      end
    end

    #
    # Represents a field of embed.
    #
    class Field < Entry
      # @return [String] The name of field.
      attr_accessor :name
      # @return [String] The value of field.
      attr_accessor :value
      # @return [Boolean] Whether the field is inline.
      attr_accessor :inline

      #
      # Initialize a new Field object.
      #
      # @param [String] name The name of field.
      # @param [String] value The value of field.
      # @param [Boolean] inline Whether the field is inline.
      #
      def initialize(name, value, inline: true)
        @name = name
        @value = value
        @inline = inline
      end

      #
      # Convert field to hash.
      #
      # @see https://discord.com/developers/docs/resources/channel#embed-object-embed-field-structure
      #   Offical Discord API Docs
      # @return [Hash] Converted field.
      #
      def to_hash
        { name: @name, value: @value, inline: @inline }
      end
    end

    #
    # Represents an image of embed.
    #
    class Image < Entry
      # @return [String] The url of image.
      attr_accessor :url
      # @return [String] The proxy url of image.
      # @return [nil] The Image object wasn't created from gateway.
      attr_reader :proxy_url
      # @return [Integer] The height of image.
      # @return [nil] The Image object wasn't created from gateway.
      attr_reader :height
      # @return [Integer] The width of image.
      # @return [nil] The Image object wasn't created from gateway.
      attr_reader :width

      #
      # Initialize a new Image object.
      #
      # @param [String] url URL of image.
      #
      def initialize(url)
        data = url
        if data.is_a? String
          @url = data
        else
          @url = data[:url]
          @proxy_url = data[:proxy_url]
          @height = data[:height]
          @width = data[:width]
        end
      end

      #
      # Convert image to hash for sending.
      #
      # @see https://discord.com/developers/docs/resources/channel#embed-object-embed-image-structure
      #   Offical Discord API Docs
      # @return [Hash] Converted image.
      #
      def to_hash
        { url: @url }
      end
    end

    #
    # Represents a thumbnail of embed.
    #
    class Thumbnail < Entry
      # @return [String] The url of thumbnail.
      attr_accessor :url
      # @return [String] The proxy url of thumbnail.
      # @return [nil] The Thumbnail object wasn't created from gateway.
      attr_reader :proxy_url
      # @return [Integer] The height of thumbnail.
      # @return [nil] The Thumbnail object wasn't created from gateway.
      attr_reader :height
      # @return [Integer] The width of thumbnail.
      # @return [nil] The Thumbnail object wasn't created from gateway.
      attr_reader :width

      #
      # Initialize a new Thumbnail object.
      #
      # @param [String] url URL of thumbnail.
      #
      def initialize(url)
        data = url
        if data.is_a? String
          @url = data
        else
          @url = data[:url]
          @proxy_url = data[:proxy_url]
          @height = data[:height]
          @width = data[:width]
        end
      end

      #
      # Convert thumbnail to hash for sending.
      #
      # @see https://discord.com/developers/docs/resources/channel#embed-object-embed-thumbnail-structure
      #   Offical Discord API Docs
      # @return [Hash] Converted thumbnail.
      #
      def to_hash
        { url: @url }
      end
    end

    #
    # Represents a video of embed.
    #
    class Video < Entry
      # @return [String] The url of video.
      attr_reader :url
      # @return [String] The proxy url of video.
      attr_reader :proxy_url
      # @return [Integer] The height of video.
      attr_reader :height
      # @return [Integer] The width of video.
      attr_reader :width

      #
      # Initialize a new Video object.
      # @private
      #
      # @param [Hash] data The data of video.
      #
      def initialize(data)
        @url = data[:url]
        @proxy_url = data[:proxy_url]
        @height = data[:height]
        @width = data[:width]
      end
    end

    #
    # Represents a provider of embed.
    #
    class Provider < Entry
      # @return [String] The name of provider.
      attr_reader :name
      # @return [String] The url of provider.
      attr_reader :url

      #
      # Initialize a new Provider object.
      # @private
      #
      # @param [Hash] data The data of provider.
      #
      def initialize(data)
        @name = data[:name]
        @url = data[:url]
      end
    end
  end
end
