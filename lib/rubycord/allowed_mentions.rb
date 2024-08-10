# typed: true
# frozen_string_literal: true

module RubyCord
  #
  # Represents a allowed mentions in a message.
  #
  class AllowedMentions
    # @return [Boolean] Whether to allow @everyone or @here.
    attr_accessor :everyone
    # @return [Boolean, Array<RubyCord::Role>] The roles to allow, or false to disable.
    attr_accessor :roles
    # @return [Boolean, Array<RubyCord::User>] The users to allow, or false to disable.
    attr_accessor :users
    # @return [Boolean] Whether to ping the user that sent the message to reply.
    attr_accessor :replied_user

    #
    # Initializes a new instance of the AllowedMentions class.
    #
    # @param [Boolean] everyone Whether to allow @everyone or @here.
    # @param [Boolean, Array<RubyCord::Guild::Role>] roles The roles to allow, or false to disable.
    # @param [Boolean, Array<RubyCord::User>] users The users to allow, or false to disable.
    # @param [Boolean] replied_user Whether to ping the user that sent the message to reply.
    #
    def initialize(everyone: nil, roles: nil, users: nil, replied_user: nil)
      @everyone = !everyone.nil?
      @roles = roles
      @users = users
      @replied_user = replied_user
    end

    # @return [String] Object class and attributes.
    def inspect
      "#<#{self.class} @everyone=#{@everyone} @roles=#{@roles} @users=#{@users} @replied_user=#{@replied_user}>"
    end

    #
    # Converts the object to a hash.
    # @private
    #
    # @param [RubyCord::AllowedMentions, nil] other The object to merge.
    #
    # @return [Hash] The hash.
    #
    def to_hash(other = nil)
      payload = { parse: %w[everyone roles users] }
      replied_user = nil_merge(@replied_user, other&.replied_user)
      everyone = nil_merge(@everyone, other&.everyone)
      roles = nil_merge(@roles, other&.roles)
      users = nil_merge(@users, other&.users)
      payload[:replied_user] = replied_user
      payload[:parse].delete("everyone") if everyone == false
      if (roles == false) || roles.is_a?(Array)
        payload[:roles] = roles.map { |u| u.id.to_s } if roles.is_a? Array
        payload[:parse].delete("roles")
      end
      if (users == false) || users.is_a?(Array)
        payload[:users] = users.map { |u| u.id.to_s } if users.is_a? Array
        payload[:parse].delete("users")
      end
      payload
    end

    # @private
    def nil_merge(*args)
      args.each { |a| return a unless a.nil? }
      nil
    end
  end
end
