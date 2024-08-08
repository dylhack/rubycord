```ruby
bundle add 'rubycord'
```

## Usage

More examples are available in [/examples](/examples) directory.

### Simple Slash Command

> ℹ️ **Info**
> You must run `rubycord setup` before using slash commands.

```ruby
# main.rb
require "rubycord"

client = RubyCord::Client.new

client.once :standby do
  puts "Logged in as #{client.user}"
end

client.slash("ping", "Ping!") do |interaction|
  interaction.post("Pong!", ephemeral: true)
end

client.run(ENV["DISCORD_BOT_TOKEN"])
```


### Legacy Message Command

```ruby
require "rubycord"

intents = RubyCord::Client::Gateway::Intents.new
intents.message_content = true

client = RubyCord::Client.new(intents: intents)

client.once :standby do
  puts "Logged in as #{client.user}"
end

client.on :message do |message|
  next if message.author.bot?
  next unless message.content == "ping"

  message.channel.post("Pong!")
end

client.run(ENV["DISCORD_BOT_TOKEN"])
```
