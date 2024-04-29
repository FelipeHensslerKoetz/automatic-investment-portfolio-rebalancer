# frozen_string_literal: true

class CurrencyParityExchangeRatesHgBrasilSyncJob
  include Sidekiq::Job

  sidekiq_options queue: 'currency_parity_exchange_rates_hg_brasil_sync', retry: false

  def perform
    CurrencyParityExchangeRatesHgBrasilSyncService.call
  end
end
