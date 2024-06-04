# frozen_string_literal: true

module Assets
  module Global
    class DiscoveryService
      attr_reader :keywords

      def initialize(keywords:)
        @keywords = keywords
      end

      def call
        assets
      end

      private

      def assets
        @assets ||= [hg_brasil_asset].compact
      end

      def hg_brasil_asset
        @hg_brasil_asset ||= Assets::HgBrasil::DiscoveryService.call(ticker_symbol: keywords)
      end
    end
  end
end
