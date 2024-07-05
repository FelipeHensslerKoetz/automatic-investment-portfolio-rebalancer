# frozen_string_literal: true

module BrApi
  module Assets
    class SyncJob
      include Sidekiq::Job

      sidekiq_options queue: 'br_api_assets_sync', retry: false

      def perform(ticker_symbols)
        BrApi::Assets::SyncService.new(ticker_symbols:).call
      end
    end
  end
end
