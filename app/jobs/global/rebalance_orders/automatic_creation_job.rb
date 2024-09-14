# frozen_string_literal: true

module Global
  module RebalanceOrders
    class AutomaticCreationJob
      include Sidekiq::Job

      sidekiq_options queue: 'global_rebalance_orders_automatic_creation', retry: false

      def perform
        check_automatic_rebalance_options_with_recurrence
      end

      private

      # TODO: create a worker to handle each automatic rebalance option execution
      def check_automatic_rebalance_options_with_recurrence
        AutomaticRebalanceOption.recurrence.find_in_batches do |automatic_rebalance_options_batch|
          automatic_rebalance_options_batch.each do |automatic_rebalance_option|
            ::Global::RebalanceOrders::AutomaticRebalanceByRecurrenceService.call(automatic_rebalance_option:)
          end
        end
      end
    end
  end
end
