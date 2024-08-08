
# frozen_string_literal: true

module RubyCord
  #
  # Represents a Discord audit log.
  #
  class Guild
    class AuditLog < RubyCord::DiscordModel
      # @return [Array<RubyCord::Guild::Webhook>] The webhooks in this audit log.
      attr_reader :webhooks
      # @return [Array<RubyCord::User>] The users in this audit log.
      attr_reader :users
      # @return [Array<RubyCord::Guild::ThreadChannel>] The threads in this audit log.
      attr_reader :threads
      # @return [Array<RubyCord::Guild::AuditLog::Entry>] The entries in this audit log.
      attr_reader :entries

      #
      # Initializes a new instance of the Guild::AuditLog class.
      # @private
      #
      def initialize(client, data, guild)
        @client = client
        @guild = guild
        @webhooks =
          data[:webhooks].map { |webhook| Guild::Webhook.from_data(@client, webhook) }
        @users =
          data[:users].map do |user|
            client.users[user[:id]] || User.new(@client, user)
          end
        @threads =
          data[:threads].map do |thread|
            client.channels[thread[:id]] ||
              Channel.make_channel(@client, thread, no_cache: true)
          end
        @entries =
          data[:audit_log_entries].map do |entry|
            Guild::AuditLog::Entry.new(@client, entry, guild.id)
          end
      end

      def inspect
        "<#{self.class} #{@entries.length} entries>"
      end

      #
      # Gets an entry from entries.
      #
      # @param [Integer] index The index of the entry.
      #
      # @return [RubyCord::Guild::AuditLog::Entry] The entry.
      # @return [nil] If the index is out of range.
      #
      def [](index)
        @entries[index]
      end
    end
  end
end

require_relative "audit_log/entry"
require_relative "audit_log/integration"
