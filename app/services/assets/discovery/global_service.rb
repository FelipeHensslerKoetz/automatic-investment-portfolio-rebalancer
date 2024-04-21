module Assets
  module Discovery
    class GlobalService
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
        @hg_brasil_asset ||= Assets::Discovery::HgBrasilService.call(symbol: keywords)
      end
    end
  end
end
