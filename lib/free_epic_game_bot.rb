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

  bot.servers.each do |_id, server|
    games.each do |game|
      server.default_channel(true).send_embed do |embed|
        embed.title = "💸 #{game.name} is now free!"
        embed.description = "Quick! Grab it while it lasts!"
        embed.url = game.url
        embed.image = Discordrb::Webhooks::EmbedImage.new url: game.cover_image
      end
    end
  end
end

bot.run
