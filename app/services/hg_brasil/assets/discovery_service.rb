# frozen_string_literal: true

module HgBrasil
  module Assets
    class DiscoveryService < System::Assets::Discovery::Base
      def self.call(ticker_symbol:)
        new(ticker_symbol:).call
      end

      def initialize(ticker_symbol:)
        super(ticker_symbol:, partner_resource_slug: 'hg_brasil_assets')
      end

      private

      def asset_details
        @asset_details ||= Integrations::HgBrasil::Assets.asset_details(ticker_symbols: ticker_symbol)&.find do |asset|
          asset[:ticker_symbol] == ticker_symbol
        end
      end
    end
  end
end
