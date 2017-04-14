require 'yaml'
require 'net/http'

list = YAML::load(File.open('urls.yaml').read)
tags_fix = YAML::load(File.open('tags_fix.yaml').read)

list.each do |item|
  uri = URI(item['url'])
  html = Net::HTTP.get(uri)
  tags_re = /<a href="\/tag\/[\S]*">([\S]*)<\/a>/
  tags = html.scan(tags_re).flatten

  category_re = /<div id="article_header">.*<a href="\/categories\/[\d]*\/posts">([\S]*)<\/a>.*<\/div>/m
  category = html.scan(category_re).flatten[0]

  date_re = /posted.*@ (.* \+0800)/
  created_at = DateTime.parse(html.scan(date_re).flatten[0])
  updated_at = DateTime.now

  title = item['title']

  yaml = <<YAML
---
title: "#{item["title"]}"
created_at: #{created_at.to_s}
updated_at: #{updated_at.to_s}
kind: article
category: #{category}
tags:
YAML

  tags.each do |tag|
    yaml += "- #{tags_fix[tag].force_encoding(Encoding::UTF_8)}\n"
  end

  yaml += <<YAML
meta:
  html: Imported from <a href="#{item['url']}">is-programmer</a>.
YAML

  yaml_file = "posts/" + created_at.strftime('%Y-%m-%d') + "-" + item["english-title"] + ".yaml"

  File.open(yaml_file, 'w') do |f|
    f.write(yaml)
  end

  org_file = "posts/" + created_at.strftime('%Y-%m-%d') + "-" + item["english-title"] + ".org"
  article_content_re = /<div id=.article_content.>(.*)<\/div>.*<div id=.article_bar.>/m
  article_content = html.scan(article_content_re).flatten[0]

  File.open('/tmp/test.html', 'w') do |f|
    f.write(article_content)
  end

  `pandoc /tmp/test.html -o #{org_file}`
end
