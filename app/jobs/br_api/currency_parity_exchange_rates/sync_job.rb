# frozen_string_literal: true

module BrApi
  module CurrencyParityExchangeRates
    class SyncJob
      include Sidekiq::Job

      sidekiq_options queue: 'br_api_currency_parity_exchange_rates_sync', retry: false

      def perform(currency_from_code, currency_to_code)
        BrApi::CurrencyParityExchangeRates::SyncService.call(currency_from_code:, currency_to_code:)
      end
    end
  end
end
