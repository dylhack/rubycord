# frozen_string_literal: true

require "bundler/gem_tasks"
require_relative "lib/rubycord/color"
task default: %i[]

# @private
def current_version
  require_relative "lib/rubycord/common"
  tag = `git tag --points-at HEAD`.force_encoding("utf-8").strip
  tag.empty? ? "main" : RubyCord::VERSION
end

desc "Run spec with parallel_rspec"
task :spec do
  sh "parallel_rspec spec/*.spec.rb spec/**/*.spec.rb"
end

desc "Build emoji_table.rb"
task :emoji_table do
  require_relative "lib/rubycord"

  iputs "Building emoji_table.rb"
  res = {}
  RubyCord::Internal::EmojiTable::DISCORD_TO_UNICODE.each do |discord, unicode|
    res[unicode] ||= []
    res[unicode] << discord
  end

  res_text = +""
  res.each do |unicode, discord|
    res_text << %(#{unicode.unpack("C*").pack("C*").inspect} => %w[#{discord.join(" ")}],\n)
  end

  table_script = File.read("lib/rubycord/emoji_table.rb")

  table_script.gsub!(
    /(?<=UNICODE_TO_DISCORD = {\n)[\s\S]+(?=}\.freeze)/,
    res_text
  )

  File.open("lib/rubycord/emoji_table.rb", "w") { |f| f.print(table_script) }
  `rufo lib/rubycord/emoji_table.rb`
  sputs "Successfully made emoji_table.rb"
end

desc "Format files"
task :format do
  Dir
    .glob("**/*.rb")
    .each do |file|
      next if file.start_with?("vendor")

      iputs "Formatting #{file}"
      `rufo ./#{file}`
      content = ""
      File.open(file, "rb") { |f| content = f.read }
      content.gsub!("\r\n", "\n")
      File.open(file, "wb") { |f| f.print(content) }
    end
end

desc "Generate document and replace"
namespace :document do
  version = current_version
  desc "Just generate document"
  task :yard do
    sh "yard -o doc/#{version} --locale #{ENV.fetch("rake_locale", nil) or "en"}"
  end

  desc "Replace files"
  namespace :replace do
    require "fileutils"

    desc "Replace CSS"
    task :css do
      iputs "Replacing css"
      Dir
        .glob("template-replace/files/**/*.*")
        .map { |f| f.delete_prefix("template-replace/files") }
        .each do |file|
          FileUtils.cp(
            "template-replace/files#{file}",
            "doc/#{version}/#{file}"
          )
        end
      sputs "Successfully replaced css"
    end

    desc "Replace HTML"
    task :html do
      require_relative "template-replace/scripts/sidebar"
      require_relative "template-replace/scripts/version"
      require_relative "template-replace/scripts/index"
      require_relative "template-replace/scripts/yard_replace"
      require_relative "template-replace/scripts/favicon"
      require_relative "template-replace/scripts/arrow"
      iputs "Resetting changes"
      Dir.glob("doc/#{version}/**/*.html") do |f|
        if (m = f.match(/[0-9]+\.[0-9]+\.[0-9]+(-[a-z]+)?/)) && m[0] != version
          next
        end

        content = File.read(f)
        content.gsub!(/<!--od-->[\s\S]*<!--eod-->/, "")
        File.write(f, content)
      end
      iputs "Adding version tab"
      %w[file_list class_list method_list].each do |f|
        replace_sidebar("doc/#{version}/#{f}.html")
      end

      iputs "Building version tab"
      build_version_sidebar("doc/#{version}", version)
      iputs "Replacing _index.html"
      replace_index("doc/#{version}", version)
      iputs "Replacing YARD credits"
      yard_replace("doc/#{version}", version)
      iputs "Adding favicon"
      add_favicon("doc/#{version}")
      iputs "Replacing arrow"
      replace_arrow("doc/#{version}")
      iputs "Successfully replaced htmls"
    end

    desc "Replace EOL"
    task :eol do
      iputs "Replacing CRLF with LF"
      Dir.glob("doc/**/*.*") do |file|
        next unless File.file?(file)
        next unless %w[html css js].include? file.split(".").last

        content = ""
        File.open(file, "rb") { |f| content = f.read }
        content.gsub!("\r\n", "\n")
        File.open(file, "wb") { |f| f.print(content) }
      end
      sputs "Successfully replaced CRLF with LF"
    end

    desc "change locale of current document"
    task :locale do
      next if ENV["rake_locale"].nil?

      require_relative "template-replace/scripts/locale_#{ENV.fetch("rake_locale", nil)}.rb"
      replace_locale("doc/main")
    end
  end
  task replace: %i[replace:css replace:html replace:eol]

  desc "Build all versions"
  task :build_all do
    require "fileutils"

    iputs "Building all versions"
    begin
      FileUtils.rm_rf("doc")
    rescue StandardError
      nil
    end
    FileUtils.cp_r("./template-replace/.", "./tmp-template-replace")
    Rake::Task["document:yard"].execute
    Rake::Task["document:replace:html"].execute
    Rake::Task["document:replace:css"].execute
    Rake::Task["document:replace:eol"].execute
    Rake::Task["document:replace:locale"].execute
    tags =
      `git tag`.force_encoding("utf-8")
        .split("\n")
        .sort_by { |t| t[1..].split(".").map(&:to_i) }
    tags.each do |tag|
      sh "git checkout #{tag} -f"
      iputs "Building #{tag}"
      FileUtils.cp_r("./tmp-template-replace/.", "./template-replace")
      version = tag.delete_prefix("v")
      Rake::Task["document:yard"].execute
      Rake::Task["document:replace:html"].execute
      Rake::Task["document:replace:css"].execute
      Rake::Task["document:replace:eol"].execute
      Rake::Task["document:replace:locale"].execute
      FileUtils.cp_r("./doc/.", "./tmp-doc")
      FileUtils.rm_rf("doc")
    end
    sh "git switch main -f"
    FileUtils.cp_r("./tmp-doc/.", "./doc")
    FileUtils.cp_r("./doc/#{tags.last.delete_prefix("v")}/.", "./doc")
    sputs "Successfully built all versions"
  rescue StandardError => e
    sh "git switch main -f"
    raise e
  end

  namespace :locale do
    desc "Generate Japanese document"
    task :ja do
      require "crowdin-api"
      require "zip"
      crowdin =
        Crowdin::Client.new do |config|
          config.api_token = ENV.fetch("CROWDIN_PERSONAL_TOKEN", nil)
          config.project_id = ENV["CROWDIN_PROJECT_ID"].to_i
        end
      build = crowdin.build_project_translation["data"]["id"]
      crowdin.download_project_translations("./tmp.zip", build)

      Zip::File.open("tmp.zip") do |zip|
        zip.each { |entry| zip.extract(entry, entry.name) { true } }
      end
      ENV["rake_locale"] = "ja"
      Rake::Task["document:yard"].execute
      Rake::Task["document:replace"].execute
    end

    desc "Generate English document"
    task :en do
      Rake::Task["document"].execute("locale:en")
    end
  end
end

task document: %i[document:yard document:replace]

desc "Lint code with rubocop"
task :lint do
  sh "rubocop lib spec Rakefile"
end

desc "Autofix code with rubocop"
task "lint:fix" do
  sh "rubocop lib spec Rakefile -A"
end
