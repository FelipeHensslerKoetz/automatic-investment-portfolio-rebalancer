# frozen_string_literal: true

module Global
  module Assets
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
        @assets ||= [br_api_asset, hg_brasil_asset].compact
      end

      def br_api_asset
        @br_api_asset ||= BrApi::Assets::DiscoveryService.call(ticker_symbol: keywords)
      end

      def hg_brasil_asset
        @hg_brasil_asset ||= HgBrasil::Assets::DiscoveryService.call(ticker_symbol: keywords)
      end
    end
  end
end
