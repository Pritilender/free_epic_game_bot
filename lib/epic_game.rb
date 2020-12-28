# frozen_string_literal: true

require "discordrb"

class EpicGame
  def self.from_raw_game(raw_game)
    EpicGame.new name: raw_game["title"],
                 slug: raw_game["productSlug"],
                 images: raw_game["keyImages"]
  end

  attr_accessor :name, :slug, :images
  private :name=, :slug=, :images=

  def initialize(name:, slug:, images:)
    self.name = name
    self.slug = slug
    self.images = images
  end

  def cover_image
    images.find { _1["type"] == "DieselStoreFrontWide" }["url"]
  end

  def url
    "https://www.epicgames.com/store/en-US/product/#{slug}"
  end
end
