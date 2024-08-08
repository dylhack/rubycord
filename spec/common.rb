# frozen_string_literal: true

require "rspec"
require "rubycord"
require "async"
require "async/rspec"

def load_payload(name, **options)
  @payloads ||= {}
  options ||= {}
  options[:symbolize_names] ||= true
  @payloads[name] ||= JSON.parse(
    File.read("#{__dir__}/payloads/#{name}"),
    **options,
  )
end

Response = Struct.new(:code, :body)
RSpec.shared_context "mocks" do # rubocop:disable RSpec/ContextWording
  def expect_request(
    method,
    path,
    body: nil,
    files: {},
    headers: nil,
    &response
  )
    $next_request = {
      method:,
      path:,
      body:,
      files:,
      headers:
    }
    $next_response = response
  end

  def expect_gateway_request(opcode, payload)
    $next_gateway_request.clear
    $next_gateway_request[:opcode] = opcode
    $next_gateway_request[:payload] = payload
  end

  let(:http) do
    http = instance_double(RubyCord::Client::HTTP)
    allow(http).to receive(:request) { |path, body, headers|
      body = nil if %i[get delete].include?(path.method)
      expect(
        {
          method: path.method,
          path: path.url,
          body:,
          files: {
          },
          headers:
        }
      ).to eq($next_request)
      Async do
        data = $next_response.call
        [Response.new(data[:code], data[:body]), data[:body]]
      end
    }
    allow(http).to receive(:multipart_request) { |path, body, files, headers|
      expect(
        {
          method: path.method,
          path: path.url,
          body:,
          files: files.to_h { |f| [f.name, f.read] },
          headers:
        }
      ).to eq($next_request)
      Async do
        data = $next_response.call
        [Response.new(data[:code], data[:body]), data[:body]]
      end
    }

    http
  end
  let(:client) do
    client = RubyCord::Client.new
    client.instance_variable_set(:@http, http)
    client.instance_variable_set(:@connection, :dummy)
    allow(client).to receive_messages(http:, handle_heartbeat: Async { nil })
    allow(client).to receive(:send_gateway) { |opcode, **payload|
      if $next_gateway_request
        expect({ opcode:, payload: }).to eq(
          $next_gateway_request
        )
      end
    }
    $next_gateway_request ||= {}

    $next_gateway_request[:opcode] = 2
    $next_gateway_request[:payload] = {
      compress: false,
      intents: RubyCord::Client::Gateway::Intents.default.value,
      properties: {
        "browser" => "rubycord",
        "device" => "rubycord",
        "os" => RUBY_PLATFORM
      },
      token: "Token"
    }

    class << client
      attr_accessor :next_gateway_request, :token
      public :handle_gateway
    end
    client.token = "Token"
    client.handle_gateway(
      load_payload("hello.json"),
      false
    ).wait
    client.handle_gateway(
      load_payload("ready.json"),
      false
    ).wait
    client.handle_gateway(
      load_payload("guild_create.json"),
      false
    ).wait
    client
  end
end

RSpec.configure do |config|
  config.include_context "mocks"
  config.include_context Async::RSpec::Reactor
end
