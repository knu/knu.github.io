#!/usr/bin/env ruby

require "yaml"
require "uri"

Dir["pages/*.md"].each do |md|
  content = File.read(md)
  basename = File.basename(md, ".md")

  content.sub!(/\A---\n(?:.*\n)*(?=---\n)/) { |frontmatter|
    yaml = YAML.load(frontmatter)
    title = yaml["title"] ||= basename
    # obsidian-github-publisher copies a link with a trailing slash
    yaml["permalink"] ||= "/#{URI.encode_uri_component(title)}/"
    YAML.dump(yaml)
  }

  File.write(md, content)
end
