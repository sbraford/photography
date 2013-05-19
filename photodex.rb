#!/Users/sbraford/.rvm/rubies/ruby-1.9.3-p327/bin/ruby

require 'pp'
require 'yaml'


$image_extensions = [".png", ".jpg", ".jpeg", ".gif"]
$dir = 'photos'
$auto_convert = {'Bw' => 'Black and White', 'Hdr' => 'HDR', 'Nw' => 'NW', 'Se' => 'SE'}
path = File.expand_path(File.dirname(__FILE__))
puts "path: #{path}"

if File.exist?('photos.yml')
  photos = YAML::load_file "photos.yml"
#  pp photos
else
  photos = {}
end
photo_path = File.join(path, $dir)
puts photo_path

Dir.glob("#{photo_path}/**/*") do |image|
  if image.chars.first != "." and image.downcase().end_with?(*$image_extensions)
    created_at = File.mtime(image)
    image = image.gsub(photo_path + '/', '')
    puts image
    if photos[image]
      puts "\tfound: #{image}"
      next
    end
    #puts "ADDING NEW photo: #{image}"
    #sleep 1
    dir, filename = *image.split('/')
    basename = filename.split('.').first
    puts "\t#{basename}"
    lc = basename.gsub('_', ' ')
    name = lc.split(' ').map(&:capitalize).join(' ')
    lc_new = []
    name.split(' ').each do |word|
      if $auto_convert[word]
        lc_new << $auto_convert[word]
      else
        lc_new << word
      end
    end
    name = lc_new.join(' ')
    puts "\t#{name}"
    photos[image] = {:name => name, :date => created_at.strftime('%Y-%m-%d')}
  end
end
pp photos

File.open("photos.yml", "w") do |file|
  file.write photos.to_yaml
end
