require 'twitter_ebooks'
require 'readability'
require 'open-uri'
require 'yaml'
require './logic.rb'


class MyBot < Ebooks::Bot
  # Configuration here applies to all MyBots
  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    config = YAML.load_file('secrets.yml')
    self.consumer_key = config['consumer_key']
    self.consumer_secret = config['consumer_secret']


    # Users to block instead of interacting with
    self.blacklist = ['tnietzschequote']

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..6
  end

  def on_startup
    @logic = Logic.new
    #tweet(@logic.generate)
    scheduler.every '24h' do
      @logic.load
      log "Reloaded logic"
    end
    scheduler.every '30m' do
      # Tweet something every 24 hours
      # See https://github.com/jmettraux/rufus-scheduler
      # tweet("hi")
      # pictweet("hi", "cuteselfie.jpg")
      tweet(@logic.generate)
    end
  end

  def on_message(dm)
    # Reply to a DM
    # reply(dm, "secret secrets")
  end

  def on_follow(user)
    # Follow a user back
    # follow(user.screen_name)
  end

  def on_mention(tweet)
    # Reply to a mention
    # reply(tweet, "oh hullo")
  end

  def on_timeline(tweet)
    # Reply to a tweet in the bot's timeline
    # reply(tweet, "nice tweet")
  end
end

# Make a MyBot and attach it to an account
MyBot.new("Transhuman_bot") do |bot|
  config = YAML.load_file('secrets.yml')
  bot.access_token = config['access_token']
  bot.access_token_secret = config['access_token_secret']
end
