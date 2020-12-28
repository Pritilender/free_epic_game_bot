# frozen_string_literal: true

require "dotenv/load"
require "discordrb"

require_relative "./epic_client"

bot = Discordrb::Bot.new token: ENV["DISCORD_TOKEN"]

puts "This bot's invite URL is #{bot.invite_url}."
puts "Click on it to invite it to your server."

bot.server_create do |event|
  event.server.default_channel(true).send_message("Hello there!")
end

bot.ready do |_event|
  games = EpicClient.new.free_games
  message = "Free games are: #{games.map { _1['title'] }.join(', ')}"

  bot.servers.each do |_id, server|
    server.default_channel(true).send_message(message)
  end
end

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run
