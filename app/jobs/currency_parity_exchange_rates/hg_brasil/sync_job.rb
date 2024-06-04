# frozen_string_literal: true

module CurrencyParityExchangeRates
  module HgBrasil
    class SyncJob
      include Sidekiq::Job

      sidekiq_options queue: 'currency_parity_exchange_rates_hg_brasil_sync', retry: false

      def perform
        CurrencyParityExchangeRates::HgBrasil::SyncService.call
      end
    end
  end
end
