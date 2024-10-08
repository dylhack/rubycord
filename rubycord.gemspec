# frozen_string_literal: true

require_relative "lib/rubycord/common"

Gem::Specification.new do |spec|
  spec.name = "rubycord"
  spec.version = RubyCord::VERSION
  spec.authors = ["Dylan Hackworth", "sevenc-nanashi"]
  spec.email = ["me@dylhack.dev"]

  spec.summary = "A Discord API wrapper for Ruby, Using socketry/async."
  spec.description = "Discord API wrapper for Ruby, Using {socketry/async}[https://github.com/socketry/async]"
  spec.homepage = "https://github.com/dylhack/rubycord"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.1")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dylhack/rubycord"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0")
        .reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
    end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "async", "~> 2.6"
  spec.add_dependency "async-http", "~> 0.60"
  spec.add_dependency "async-websocket", "~> 0.25"

  spec.add_dependency "dotenv", "~> 2.8"
  spec.add_dependency "mime-types", "~> 3.4"
  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
