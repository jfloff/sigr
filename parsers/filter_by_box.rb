#!/usr/bin/env ruby

require 'open-uri'
require 'zlib'
require 'json'

def within_box?(box, point)
  box_lons = [box[:ne][:lon], box[:sw][:lon]]
  box_lats = [box[:ne][:lat], box[:sw][:lat]]
  return (point[:lon].between?(box_lons.min, box_lons.max) && point[:lat].between?(box_lats.min, box_lats.max))
end

# NE 49.590370, -66.932640
# SW 24.949320, -125.001106

box = {
  ne: {
    lat: 49.590370,
    lon: -66.932640
  },
  sw: {
    lat: 24.949320,
    lon: -125.001106
  }
}
out_file = File.open("data/us_geo_tweets", "w")


geo_tweets = 'data/geo_tweets'

File.open(geo_tweets).read.each_line do |tweet_json|
  tweet = JSON.parse(tweet_json)

  point = {
    lat: tweet['coordinates']['lat'],
    lon: tweet['coordinates']['lon'],
  }

  utf8_tweet = JSON.generate({
    text: tweet['text'].encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '').delete("\n"),
    coordinates: point,
  });

  if within_box?(box, point)
    out_file.write(utf8_tweet + "\n")
  end

end

out_file.close
