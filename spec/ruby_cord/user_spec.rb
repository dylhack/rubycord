# frozen_string_literal: true

require_relative "../common"

RSpec.describe RubyCord::User do
  %w[new_user user bot].each do |data_name|
    context "with #{data_name} data" do
      let(:data) do
        load_payload("users/#{data_name}.json")
      end
      let(:user) { described_class.new(client, data) }

      it "initializes successfully" do
        expect { user }.not_to raise_error
      end

      describe "parsing" do
        specify "#id returns the id as Snowflake" do
          expect(user.id).to be_a RubyCord::Snowflake
          expect(user.id).to eq data[:id]
        end

        specify "#name returns the name" do
          expect(user.name).to eq data[:username]
        end

        specify "#avatar returns Avatar object" do
          expect(user.avatar).to be_a RubyCord::User::Avatar
        end
      end

      describe "helpers" do
        if data_name == "new_user"
          specify "#to_s returns name with `Global name (@Username)` format" do
            expect(
              user.to_s
            ).to eq "#{data[:global_name]} (@#{data[:username]})"
          end
        else
          specify "#to_s returns name with `name#discriminator` format" do
            expect(user.to_s).to eq "#{data[:username]}##{data[:discriminator]}"
          end
        end

        specify "#mention returns `<@user_id>`" do
          expect(user.mention).to eq "<@#{data[:id]}>"
        end

        specify "#bot? returns true if user is bot" do
          expect(user.bot?).to eq data[:bot] == true
        end
      end
    end
  end
end
