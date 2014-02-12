#!/usr/bin/ruby
#
# Dumpmon-mon v0.1.1 (2014-02-12)
# By Glenn 'devalias' Grant (devalias.net)
#

# TODO: Refactor this into methods and stuff.

# require 'chatterbot/dsl'
require 'yaml'
require 'twitter'
require 'mechanize'

# Filenames
script_name = File.basename($0, File.extname($0))
config_file_name = "#{script_name}.yml"

# Load config
config_file = YAML.load_file(config_file_name)

config = config_file[:config]

monitored_config = config[:monitored]
monitored_strings = monitored_config[:strings]

twitter_config = config_file[:twitter]
twitter_auth = twitter_config[:auth]
twitter_monitored_users = twitter_config[:monitored_users]

state_config = config_file[:state]
last_tweet_id = state_config[:last_tweet_id]

puts "Last tweet ID #{last_tweet_id}"

# Configure Twitter gem
Twitter.configure do |config|
  config.consumer_key = twitter_auth[:consumer_key]
  config.consumer_secret = twitter_auth[:consumer_secret]
  config.oauth_token = twitter_auth[:token]
  config.oauth_token_secret = twitter_auth[:secret]
end


# Generate a collection of monitored user->tweets->urls
# TODO: Should this be nested, or should we split it up?
puts "Checking #{twitter_monitored_users.count} twitter user(s) tweets for URLs."
results = twitter_monitored_users.each.map do |user|
  puts "  User: #{user}"

  # Ref: http://rdoc.info/gems/twitter/Twitter/API/Timelines
  #    Options Hash (options):
  #      :since_id (Integer) — Returns results with an ID greater than (that is, more recent than) the specified ID.
  #      :max_id (Integer) — Returns results with an ID less than (that is, older than) or equal to the specified ID.
  #      :count (Integer) — Specifies the number of records to retrieve. Must be less than or equal to 200.
  #      :trim_user (Boolean, String, Integer) — Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
  #      :exclude_replies (Boolean, String, Integer) — This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets - this is because the count parameter retrieves that many tweets before filtering out retweets and replies.
  #      :contributor_details (Boolean, String, Integer) — Specifies that the contributors element should be enhanced to include the screen_name of the contributor.
  #      :include_rts (Boolean, String, Integer) — Specifies that the timeline should include native retweets in addition to regular tweets. Note: If you're using the trim_user parameter in conjunction with include_rts, the retweets will no longer contain a full user object.
  user_timeline_options = {
    :trim_user => true,
    :include_rts => false,
    :since_id => last_tweet_id,
    :count => twitter_config[:max_tweet_count]
  }

  tweets = Twitter.user_timeline(user, user_timeline_options).reverse_each.map do |tweet|
    # puts "#{tweet.created_at} #{tweet.id} #{last_tweet_id - tweet.id}"
    # puts tweet.inspect
    last_tweet_id = tweet.id # TODO: update config file when we do this

    urls = tweet.urls.map do |url|
      # puts "    #{url.expanded_url}"

      # Return value
      url = url.expanded_url
    end

    # Return value
    tweet = {
      :id => tweet.id,
      :created_at => tweet.created_at,
      :urls => urls
    }
  end

  # Return value
  user = {
    :user_name => user,
    :tweets => tweets
  }
end
puts "Done!"

# puts "#{results.inspect}\n\n"

# Start the mechanize stuff
agent = Mechanize.new

# Load
puts "Checking tweeted urls on #{results.count} user(s) for #{monitored_strings.count} monitored string(s)."
# For each monitored user (result)
results.each do |user|
  puts "  User: #{user[:user_name]}" # TODO: Move this out of here?

  # For each tweet
  user[:tweets].each do |tweet|
    puts "    Tweet Id: #{tweet[:id]}" # TODO: Move this out of here?

    # For each url
    begin
      url_matches = tweet[:urls].each.map do |url|
        page = agent.get(url) # Load the page

        # For each monitored string
        string_matches = monitored_strings.each.map do |check_string|
          # puts "  String: #{check_string}"

          # For each match
          matches = page.body.scan(check_string)
          # matches = page.body.scan(check_string).map do |match|
          #   # puts "      Match: #{match}"
          #   # Return value
          #   match = match
          # end

          # Return value
          check_string = {
            :name => check_string,
            :matches => matches
          }
        end # End for each monitored string

        # Return value
        url = {
          :url => url,
          :matches => string_matches
        }
      end # For each url

      # TODO: can probably seperate this display from the actual checking?
      # For each found match
      url_matches.each do |url_match|
        puts "      URL: #{url_match[:url]})"
        puts "        Matches:"
        url_match[:matches].each do |string_match|
          match_name = string_match[:name]
          match_count = string_match[:matches].count
          if match_count > 0
            puts "        #{match_count} (#{match_name})"
          end
        end
      end

    rescue Mechanize::ResponseCodeError => e
      puts "      Error: #{e.response_code} received for #{e.page.uri}"
    rescue Exception => e
      # TODO: Generalise this for all exception handling?
      STDERR.puts "----------------------------------------"
      STDERR.puts " Exception"
      STDERR.puts "----------------------------------------"
      STDERR.puts e.message
      STDERR.puts e.backtrace.inspect
      STDERR.puts "----------------------------------------"
      STDERR.puts "Please report this exception output in full at https://github.com/alias1/dumpmonmon/issues"
      STDERR.puts "----------------------------------------"
      abort("Quitting: Unhandled Exception Occured")
    end # Error checking
  end # For each tweet
end # For each monitored user

puts "Note: The last checked tweet ID was #{last_tweet_id}. For now, this will need to be manually updated in dumpmonmon.yml"

# /response/raise_error.rb:21:in `on_complete': Error processing your OAuth request: Read-only application cannot POST (Twitter::Error::Unauthorized)
# /response/raise_error.rb:21:in `on_complete': Status is a duplicate (Twitter::Error::Forbidden)
