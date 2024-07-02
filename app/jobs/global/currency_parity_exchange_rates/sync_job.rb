# frozen_string_literal: true

module Global
  module CurrencyParityExchangeRates
    class SyncJob
      include Sidekiq::Job

      sidekiq_options queue: 'global_currency_parity_exchange_rates_sync', retry: false

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

      # pegar com transaction
      def hg_brasil_currency_parity_exchange_rates
        @hg_brasil_currency_parity_exchange_rates = CurrencyParityExchangeRate.updated.where(partner_resource: hg_brasil_partner_resource)
      end

      def hg_brasil_sync
        hg_brasil_currency_parity_exchange_rates.each(&:schedule!) # passar em uma transaction

        HgBrasil::CurrencyParityExchangeRates::SyncJob.perform_async
      end
    end
  end
end
