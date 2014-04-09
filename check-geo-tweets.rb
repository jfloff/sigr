#!/usr/bin/env ruby

require 'open-uri'
require 'zlib'
require 'json'


Zlib::GzipReader.open('geo_tweets.gz').read.each_line do |gz|
  print gz.read
end


