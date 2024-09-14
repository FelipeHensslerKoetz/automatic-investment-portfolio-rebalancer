# frozen_string_literal: true

module Global
  module RebalanceOrders
    class ProcessJob
      include Sidekiq::Job

      sidekiq_options queue: 'global_rebalance_orders_process', retry: false

      # TODO: redis-lock
      def perform
        return if asset_price_or_currency_parity_exchange_rate_being_updated?

        pending_rebalance_orders.find_in_batches.each do |rebalance_order_batch|
          rebalance_order_batch.each do |rebalance_order|
           
            rebalance_order.schedule!
            System::Rebalances::CalculatorService.call(rebalance_order_id: rebalance_order.id)
          end
        end
      end

      private

      def asset_price_or_currency_parity_exchange_rate_being_updated?
        CurrencyParityExchangeRate.scheduled.any? ||
          CurrencyParityExchangeRate.processing.any? ||
          AssetPrice.scheduled.any? ||
          AssetPrice.processing.any?
      end

      def pending_rebalance_orders
        RebalanceOrder.pending.where(scheduled_at: Time.zone.today)
      end
    end
  end
end
