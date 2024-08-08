# frozen_string_literal: true

require_relative "../../common"

RSpec.describe RubyCord::Guild::TextChannel do
  let(:channel) do
    RubyCord::Guild::TextChannel.new(
      client,
      load_payload("channels/text_channel.json"),
    )
  end

  it "initializes successfully" do
    expect { channel }.not_to raise_error
  end

  it "posts message" do
    expect_request(
      :post,
      "/channels/863581274916913196/messages",
      body: {
        allowed_mentions: {
          parse: %w[everyone roles users],
          replied_user: nil
        },
        attachments: [],
        content: "msg",
        tts: false
      }
    ) do
      {
        code: 200,
        body: load_payload("message.json")
      }
    end
    expect(channel.post("msg").wait).to be_a RubyCord::Message
  end

  it "creates new invite" do
    expect_request(
      :post,
      "/channels/863581274916913196/invites",
      body: {
        max_age: 0,
        max_uses: 1,
        temporary: false,
        unique: false
      },
      headers: {
        audit_log_reason: nil
      }
    ) do
      {
        code: 200,
        body: load_payload("invite.json")
      }
    end
    expect(
      channel.create_invite(
        max_age: 0,
        max_uses: 1,
        temporary: false,
        unique: false
      ).wait
    ).to be_a RubyCord::Guild::Invite
  end

  it "creates new thread" do
    expect_request(
      :post,
      "/channels/863581274916913196/threads",
      body: {
        auto_archive_duration: nil,
        name: "thread",
        rate_limit_per_user: nil,
        type: 11
      },
      headers: {
        audit_log_reason: nil
      }
    ) do
      {
        code: 200,
        body: load_payload("channels/thread_channel.json")
      }
    end
    expect(
      channel.create_thread("thread").wait
    ).to be_a RubyCord::Guild::ThreadChannel
  end

  describe "permissions" do
    it "returns { RubyCord::Guild::Member, RubyCord::Guild::Role => RubyCord::PermissionOverwrite }" do
      expect(channel.permission_overwrites).to be_a Hash
      expect(channel.permission_overwrites.keys).to all(
        satisfy { |k| k.is_a?(RubyCord::Guild::Role) || k.is_a?(RubyCord::Guild::Member) }
      )
      expect(channel.permission_overwrites.values).to all(
        satisfy { |k| k.is_a?(RubyCord::PermissionOverwrite) }
      )
    end
  end
end
