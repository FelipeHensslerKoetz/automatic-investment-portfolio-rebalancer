# frozen_string_literal: true

module Assets
  module HgBrasil
    class SyncJob
      include Sidekiq::Job

      sidekiq_options queue: 'assets_hg_brasil_sync', retry: false

      def perform(ticker_symbols)
        Assets::HgBrasil::SyncService.new(ticker_symbols:).call
      end
    end
  end
end
