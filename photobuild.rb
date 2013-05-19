#!/Users/sbraford/.rvm/rubies/ruby-1.9.3-p327/bin/ruby

require 'pp'
require 'yaml'


$image_extensions = [".png", ".jpg", ".jpeg", ".gif"]
$dir = 'photos'
$index_limit = 21
path = File.expand_path(File.dirname(__FILE__))
puts "path: #{path}"

if File.exist?('photos.yml')
  photos = YAML::load_file "photos.yml"
  pp photos
else
  puts "photos.yml file does not exist yet. run ./photodex.rb first"
  return
end
dates = []
date_hash = {}
photos.each_pair do |photo, v|
  name = v[:name]
  date = v[:date]
  dates << date
  puts photo
  photo_hash = {:name => name, :date => date, :photo => photo}
  if date_hash[date]
    date_hash[date] << photo_hash
  else
    date_hash[date] = [photo_hash]
  end
  puts "\t#{date} :: #{name}"
  photo_path = "/photos/#{photo}"

  name_slug = name.downcase.gsub(' ', '-')
  post_slug = "#{date}-#{name_slug}"
  puts post_slug
  post_path = File.join(path, '_posts', 'photos', "#{post_slug}.md")

  if File.exist?(post_path)
    puts "\tAlready exists: #{post_path} SKIPPING"
    next
  end
  post = <<EOF
---
layout: post
category: photos
description: #{name} photo by Shanti Braford Photography
---
{% include JB/setup %}

<a href="#{photo_path}" title="#{name}"><img src="#{photo_path}" alt="#{name}" /></a>

EOF

  puts post
  puts "Writing to: #{post_path}"

  File.open(post_path, 'w') { |f| f.write(post) }

end

## Build Index
dates.uniq!
dates.sort!
dates.reverse!
puts "Dates: #{dates.inspect}"
html = '<center>'
count = 0
dates.each do |date|
  break if count >= $index_limit
  photos = date_hash[date]
  photos.each do |photo|
    next if count >= $index_limit
    path = photo[:photo]
    name = photo[:name]
    photo_path = "/photos/#{path}"
    dir, image_filename = *path.split('/')
    thumb_path = "/photos/#{dir}/thumbs/#{image_filename}"
    photo_html = <<EOF
<div class="index-photo">
<a href="#{photo_path}" title="#{name}"><img src="#{thumb_path}" alt="#{name}" /></a>
</div>
EOF
    html << photo_html
    count += 1

  end
end
html << '</center>'
index_template = IO.read('index_template.md')
index_template.gsub!('###PHOTOS###', html)
File.open('index.md', 'w') { |f| f.write(index_template) }
