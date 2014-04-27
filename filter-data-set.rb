#!/usr/bin/env ruby

require 'open-uri'
require 'zlib'
require 'json'

def within_box?(box, point)
  box_lons = [box[:ne][:lon], box[:sw][:lon]]
  box_lats = [box[:ne][:lat], box[:sw][:lat]]
  return (point[:lon].between?(box_lons.min, box_lons.max) && point[:lat].between?(box_lats.min, box_lats.max))
end

# location = 'tweets01_aaaa.gz'
# location = 'http://dmir.inesc-id.pt/shinra/~bmartins/twitter-data/data/tweets01_aaaa.gz'
# location = ARGV[0];

# MIAMI Bounding Box:
# NE 25.855700, -80.142387
# SW 25.709000, -80.319611

city_box = {
  ne: {
    lat: 25.855700,
    lon: -80.142387
  },
  sw: {
    lat: 25.709000,
    lon: -80.319611
  }
}

file_list = ARGV[0]
# base_path = './'
base_path = 'http://dmir.inesc-id.pt/shinra/~bmartins/twitter-data/data/'

File.open(file_list).read.each_line do |filename|
  puts "Parsing #{filename.chomp} ..."
  File.open("geo_#{filename[0...-4]}.gz", 'w') do |write_file|
    write_gz = Zlib::GzipWriter.new(write_file)

    file = open(base_path + filename.chomp)
    gz = Zlib::GzipReader.new(file, {encoding: Encoding::UTF_8})

    begin
      gz.each_line do |tweet_json|
        tweet = JSON.parse(tweet_json)
        if !tweet['coordinates'].nil?
          msg = tweet['text']
          coordinates = {
            lat: tweet['coordinates']['coordinates'][1],
            lon: tweet['coordinates']['coordinates'][0]
          }

          simple_tweet = JSON.generate({
            text: msg,
            coordinates: coordinates,
          });

          write_gz.write(simple_tweet + "\n")
          # if within_box?(city_box, tweet_coordinates)
          #   puts JSON.pretty_generate(tweet)
          # end
        end
      end
    ensure
      gz.close
      write_gz.close
    end
  end
  puts "Parsing #{filename.chomp} ended"
end
puts "The End."
