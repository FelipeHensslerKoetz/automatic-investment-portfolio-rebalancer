# frozen_string_literal: true

module CurrencyParityExchangeRates
  module Global
    class SyncJob
      include Sidekiq::Job

      sidekiq_options queue: 'currency_parity_exchange_rates_global_sync', retry: false

      def perform
        return if any_rebalance_order_being_processed?

        hg_brasil_sync
      end

      private

      def any_rebalance_order_being_processed?
        RebalanceOrder.processing.any?
      end

      def hg_brasil_partner_resource
        @hg_brasil_partner_resource = PartnerResource.find_by(slug: 'hg_brasil_quotation')
      end

      def hg_brasil_currency_parity_exchange_rates
        @hg_brasil_currency_parity_exchange_rates = CurrencyParityExchangeRate.updated.where(partner_resource: hg_brasil_partner_resource)
      end

      def hg_brasil_sync
        hg_brasil_currency_parity_exchange_rates.each(&:schedule!)

        CurrencyParityExchangeRates::HgBrasil::SyncJob.perform_async
      end
    end
  end
end
