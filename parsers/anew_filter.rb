#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'csv'
require 'unicode_utils/downcase'


data_dir = '/Users/jfloff/Code/HappiTweet/data/'

us_anew_words = {}
us_anew_words_file = data_dir + "hedonometer_anew.csv"
CSV.foreach(us_anew_words_file) do |row|
  word = UnicodeUtils.downcase(row[0])
  score = row[1].to_f

  us_anew_words[word] = score
end

es_anew_words = {}
es_anew_words_file = data_dir + "es_anew.csv"
CSV.foreach(es_anew_words_file) do |row|
  word = UnicodeUtils.downcase(row[0])
  score = row[1].to_f

  es_anew_words[word] = score
end

geo_tweets = data_dir + "us_geo_tweets"
test_file = File.open(geo_tweets + "_hedonometer_anew", "w")
File.open(geo_tweets).read.each_line do |tweet_json|
  tweet = JSON.parse(tweet_json)

  anew_tweet = {}

  # coordinates in tweet
  point = {
    lat: tweet['coordinates']['lat'],
    lon: tweet['coordinates']['lon'],
  }

  anew_tweet['coordinates'] = point

  # downcase for comparation with anew words
  msg = UnicodeUtils.downcase(tweet['text'])
  anew_tweet['msg'] = msg

  # count number of anew words
  tweet_us_anew_words = Hash.new 0
  total_us_anew_words = 0
  msg.split.each do |word|
    if us_anew_words.has_key?(word)
      tweet_us_anew_words[word] += 1
      total_us_anew_words += 1
    end
  end

  # count number of anew words
  tweet_es_anew_words = Hash.new 0
  total_es_anew_words = 0
  msg.split.each do |word|
    if es_anew_words.has_key?(word)
      tweet_es_anew_words[word] += 1
      total_es_anew_words += 1
    end
  end

  # if has any anew word calculates score
  if total_us_anew_words > 0 || total_es_anew_words > 0

    if total_es_anew_words > total_us_anew_words
      anew_words = es_anew_words
      tweet_anew_words = tweet_es_anew_words
    else
      anew_words = us_anew_words
      tweet_anew_words = tweet_us_anew_words
    end

    # counts the words and the score for each word
    # sums the total number of words and the total scoe
    total_words = 0
    total_score = 0
    tweet_anew_words.each do |word,count|
      total_words += count
      total_score += anew_words[word] * count
    end

    # give the final score by
    anew_tweet['anew_score'] = total_score / total_words

    test_file.write(JSON.generate(anew_tweet) + "\n")
  end
end

test_file.close
