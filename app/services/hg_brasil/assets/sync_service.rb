# frozen_string_literal: true

module HgBrasil
  module Assets
    class SyncService < System::Assets::Sync::Base
      def self.call(ticker_symbols:)
        new(ticker_symbols:).call
      end

      def initialize(ticker_symbols:)
        super(ticker_symbols:, partner_resource_slug: 'hg_brasil_stock_price')
      end

      private

      def fetch_asset_details
        @fetch_asset_details ||= ::HgBrasil::Stocks.asset_details(ticker_symbols:)
      end
    end
  end
end
