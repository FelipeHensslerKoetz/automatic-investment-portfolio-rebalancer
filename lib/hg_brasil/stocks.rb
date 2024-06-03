# frozen_string_literal: true

module HgBrasil
  class Stocks < HgBrasil::Base
    def self.asset_details(ticker_symbols:)
      new.asset_details(ticker_symbols:)
    end

    def asset_details(ticker_symbols:)
      response ||= get(url: '/stock_price', params: { symbol: ticker_symbols })&.dig('results')

      return if request_error?(response)

      response.each_value.map do |asset|
        next if asset['error']

        formatted_asset_details(asset)
      end.compact
    end

    private

    def request_error?(response)
      response.blank? || response['error'] || !response.is_a?(Hash)
    end

    def formatted_asset_details(asset)
      {
        ticker_symbol: asset['symbol'].upcase,
        kind: asset['kind'],
        name: asset['company_name'] || asset['name'],
        price: asset['price'],
        reference_date: Time.zone.parse(asset['updated_at']),
        currency: asset['currency']
      }
    end
  end
end
