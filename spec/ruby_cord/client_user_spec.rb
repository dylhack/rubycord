
# frozen_string_literal: true

require_relative "../common"

RSpec.describe RubyCord::Client::User do
  it "sends PATCH /users/@me" do
    expect_request(:patch, "/users/@me", body: { username: "new_name" }) do
      { code: 200, body: {} }
    end

    client.user.edit(name: "new_name").wait
  end
end
