#!/usr/bin/env ruby

require "shellwords"
require "time"
require "uri"
require "yaml"

Dir["pages/*.md"].each do |md|
  content = File.read(md)
  basename = File.basename(md, ".md")

  content.sub!(/\A---\n(?:.*\n)*(?=---\n)/) { |frontmatter|
    yaml = YAML.load(frontmatter, permitted_classes: [Date, Time])
    title = yaml["title"] ||= basename
    # obsidian-github-publisher copies a link with a trailing slash
    yaml["permalink"] ||= "/#{URI.encode_uri_component(title)}/"
    yaml["date"] ||= Time.parse(`git log --diff-filter=A --pretty="format:%ci" -- #{md.shellescape}`.chomp).iso8601
    yaml["lastmod"] ||= Time.parse(`git log -1 --pretty="format:%ci" -- #{md.shellescape}`.chomp).iso8601
    YAML.dump(yaml)
  }

  File.write(md, content)
end
