#!/usr/bin/env ruby

require 'open-uri'
require 'zlib'
require 'json'

def within_box?(box, point)
  box_lons = [box[:ne][:lon], box[:sw][:lon]]
  box_lats = [box[:ne][:lat], box[:sw][:lat]]
  return (point[:lon].between?(box_lons.min, box_lons.max) && point[:lat].between?(box_lats.min, box_lats.max))
end

def filter_tweet(tweet, keys)
  new_tweet = {}
  keys.each do |key|
    new_tweet[key] = tweet[key]
  end
  return new_tweet
end

location = 'tweets01_aaaa.gz'
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

File.open("file_list.txt").each_line do |file|
  puts file
  exit
  Zlib::GzipReader.open(location).each_line do |tweet_json|
    tweet = JSON.parse(tweet_json)
    if !tweet['coordinates'].nil?
      # check if coordinates is empty??
      tweet_coordinates = {
        lat: tweet['coordinates']['coordinates'][1],
        lon: tweet['coordinates']['coordinates'][0]
      }
      parsed_tweet = filter_tweet(tweet, ['text','coordinates'])
      puts JSON.pretty_generate(parsed_tweet)

      # if within_box?(city_box, tweet_coordinates)
      #   puts JSON.pretty_generate(tweet)
      # end
    end
  end
  exit
end
