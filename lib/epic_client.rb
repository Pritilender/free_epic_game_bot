# frozen_string_literal: true

require "http"
require "oj"
require_relative "./epic_game"

class EpicClient
  HttpError = Class.new StandardError
  BASE_URL = "https://www.epicgames.com/graphql"

  #
  # List all free games. These are the games that usually have some price, but currently this price is 0.
  #
  def free_games(time: Time.now)
    request(query: free_games_query(time: time))
      .then { _1.dig("data", "Catalog", "searchStore", "elements") }
      .then { |games| games.map { EpicGame.from_raw_game _1 } }
  end

  private

  def request(query:)
    response = HTTP.post BASE_URL, json: query
    body = Oj.load response.body.to_s
    raise HttpError, body unless response.status.success?

    body
  end

  def free_games_query(time:) # rubocop:disable Metrics/MethodLength
    time = time.utc.iso8601 3
    {
      "query": "query searchStoreQuery($allowCountries: String, $category: String, $count: Int, $country: String!,
                                         $locale: String, $withPrice: Boolean = true, $freeGame: Boolean,
                                         $onSale: Boolean, $effectiveDate: String) {
        Catalog {
          searchStore(allowCountries: $allowCountries, category: $category, count: $count, country: $country,
                        locale: $locale, freeGame: $freeGame, onSale: $onSale, effectiveDate: $effectiveDate) {
            elements {
              title
              id
              namespace
              productSlug
              keyImages {
                type
                url
              }
              items {
                id
                namespace
              }
              price(country: $country) @include(if: $withPrice) {
                totalPrice {
                  discountPrice
                  originalPrice
                }
              }
            }
            paging {
              count
              total
            }
          }
        }
      }",
      "variables": {
        "allowCountries": "RS,DE",
        "category": "games/edition/base|bundles/games",
        "count": 100,
        "country": "RS",
        "effectiveDate": "[,#{time}]",
        "freeGame": true,
        "locale": "en-US",
        "withPrice": true,
        "onSale": true
      }
    }
  end
end
