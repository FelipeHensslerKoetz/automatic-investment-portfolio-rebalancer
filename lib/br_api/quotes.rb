# frozen_string_literal: true

module BrApi
  class Quotes < BrApi::Base
    def self.asset_details(ticker_symbols:)
      new.asset_details(ticker_symbols:)
    end

    def asset_details(ticker_symbols:)
      response ||= get(url: "/quote/#{ticker_symbols}")

      return [] if request_error?(response)

      response['results'].map { |asset_details| formatted_asset_details(asset_details) }.compact_blank
    end

    private

    def request_error?(response)
      response.blank? || response['error'] || !response['results'].is_a?(Array)
    end

    def formatted_asset_details(asset_details)
      return {} unless all_required_keys_present?(asset_details)

      {
        ticker_symbol: asset_details['symbol'].upcase,
        kind: resolve_kind(asset_details),
        name: asset_details['longName'],
        price: asset_details['regularMarketPrice'],
        currency: asset_details['currency'],
        reference_date: asset_details['regularMarketTime']
      }
    end

    def all_required_keys_present?(asset_details)
      %w[symbol longName shortName regularMarketPrice currency regularMarketTime].all? { |key| asset_details.key?(key) }
    end

    def resolve_kind(asset_details)
      long_name = asset_details['longName'].downcase
      short_name = asset_details['shortName'].downcase

      if long_name.match?(/fundo de investimento imobiliario|\bfii\b/) || short_name.match?(/\bfii\b/)
        'fii'
      elsif long_name.match?(/index|fundo|fund/)
        'etf'
      else
        'stock'
      end
    end
  end
end
