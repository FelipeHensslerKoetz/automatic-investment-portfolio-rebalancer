# frozen_string_literal: true

class AssetsHgBrasilSyncJob
  include Sidekiq::Job

  sidekiq_options queue: 'assets_hg_brasil_sync', retry: false

  def perform(ticker_symbols)
    AssetsHgBrasilSyncService.new(ticker_symbols:).call
  end
end
