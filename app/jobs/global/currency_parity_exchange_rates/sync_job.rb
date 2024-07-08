# frozen_string_literal: true

module Global
  module CurrencyParityExchangeRates
    class SyncJob
      include Sidekiq::Job

      sidekiq_options queue: 'global_currency_parity_exchange_rates_sync', retry: false

      def perform
        return if any_rebalance_order_being_processed?

        hg_brasil_currency_parity_exchanges_sync
        br_api_currency_parity_exchange_rates_sync
      end

      private

      def any_rebalance_order_being_processed?
        RebalanceOrder.processing.any?
      end

      def hg_brasil_partner_resource
        @hg_brasil_partner_resource = PartnerResource.find_by(slug: 'hg_brasil_currencies')
      end

      def hg_brasil_currency_parity_exchange_rates
        @hg_brasil_currency_parity_exchange_rates = CurrencyParityExchangeRate.pending.where(partner_resource: hg_brasil_partner_resource)
      end

      def hg_brasil_currency_parity_exchanges_sync
        hg_brasil_currency_parity_exchange_rates.each(&:schedule!)

        HgBrasil::CurrencyParityExchangeRates::SyncJob.perform_async
      end

      def br_api_partner_resource
        @br_api_partner_resource = PartnerResource.find_by(slug: 'br_api_currencies')
      end

      def br_api_currency_parity_exchange_rates
        @br_api_currency_parity_exchange_rates = CurrencyParityExchangeRate.pending.where(partner_resource: br_api_partner_resource)
      end

      def br_api_currency_parity_exchange_rates_sync
        delay_in_seconds = 0

        br_api_currency_parity_exchange_rates.each do |currency_parity_exchange_rate|
          currency_parity_exchange_rate.schedule!
          if currency_parity_exchange_rate.scheduled?
            BrApi::CurrencyParityExchangeRates::SyncJob.perform_in(
              delay_in_seconds.seconds,
              currency_parity_exchange_rate.currency_parity.currency_from.code,
              currency_parity_exchange_rate.currency_parity.currency_to.code
            )
          end
          delay_in_seconds += br_api_schedule_delay_in_seconds
        end
      end

      def br_api_schedule_delay_in_seconds
        @br_api_schedule_delay_in_seconds ||= Rails.application.credentials.br_api[:request_delay_in_seconds]
      end
    end
  end
end
