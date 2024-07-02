# frozen_string_literal: true

module HgBrasil
  module CurrencyParityExchangeRates
    class SyncJob
      include Sidekiq::Job

      sidekiq_options queue: 'hg_brasil_currency_parity_exchange_rates_sync', retry: false

      def perform
        HgBrasil::CurrencyParityExchangeRates::SyncService.call
      end
    end
  end
end
