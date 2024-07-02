# frozen_string_literal: true

module HgBrasil
  module Assets
    class SyncJob
      include Sidekiq::Job

      sidekiq_options queue: 'hg_brasil_assets_sync', retry: false

      def perform(ticker_symbols)
        HgBrasil::Assets::SyncService.new(ticker_symbols:).call
      end
    end
  end
end
