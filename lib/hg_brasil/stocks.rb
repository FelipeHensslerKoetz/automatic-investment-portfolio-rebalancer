# frozen_string_literal: true

require 'hg_brasil/base'

module HgBrasil
  class Stocks < HgBrasil::Base
    def self.asset_details(symbol:)
      new.asset_details(symbol:)
    end

    def self.asset_details_batch(symbols:)
      new.asset_details_batch(symbols:)
    end

    def asset_details(symbol:)
      response ||= get(url: '/stock_price', params: { 'symbol' => symbol })&.dig('results', symbol.upcase)

      return nil if response.blank? || response['error']

      {
        ticker_symbol: response['symbol'].upcase,
        kind: response['kind'],
        name: response['company_name'] || response['name'],
        price: response['price'],
        reference_date: Time.zone.parse(response['updated_at']),
        currency: response['currency']
      }
    end

    def asset_details_batch(symbols:)
      response ||= get(url: '/stock_price', params: { symbol: symbols })&.dig('results')

      return nil if response.blank? || response['error'] || !response.is_a?(Hash)

      formatted_response = []

      response.each_value do |value|
        next if value['error']

        formatted_response << {
          ticker_symbol: value['symbol'].upcase,
          kind: value['kind'],
          name: value['company_name'] || value['name'],
          price: value['price'],
          reference_date: Time.zone.parse(value['updated_at']),
          currency: value['currency']
        }
      end

      formatted_response
    end
  end
end
