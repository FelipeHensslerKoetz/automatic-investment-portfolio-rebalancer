# frozen_string_literal: true

module BrApi
  module Assets
    class DiscoveryService < System::Assets::Discovery::Base
      def self.call(ticker_symbol:)
        new(ticker_symbol:).call
      end

      def initialize(ticker_symbol:)
        super(ticker_symbol:, partner_resource_slug: 'br_api_assets')
      end

      def asset_details
        @asset_details ||= Integrations::BrApi::Assets.asset_details(ticker_symbols: ticker_symbol)&.find do |asset|
          asset[:ticker_symbol] == ticker_symbol
        end
      end
    end
  end
end
