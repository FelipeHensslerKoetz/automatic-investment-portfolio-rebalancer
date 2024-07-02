# frozen_string_literal: true

module BrApi
  module Assets
    class SyncService < System::Assets::Sync::Base
      def self.call(ticker_symbols:)
        new(ticker_symbols:).call
      end

      def initialize(ticker_symbols:)
        super(ticker_symbols:, partner_resource_slug: 'br_api_quotation')
      end

      private

      def fetch_asset_details
        @fetch_asset_details ||= ::BrApi::Quotes.asset_details(ticker_symbols:)
      end
    end
  end
end
