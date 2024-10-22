module System 
  module Rebalances 
    class RebalanceOrderValidationService 
      attr_reader :rebalance_order

      def initialize(rebalance_order:)
        @rebalance_order = rebalance_order
      end

      def self.call(rebalance_order:)
        new(rebalance_order: rebalance_order).call
      end

      def call
        validate_rebalance_order_rebalance_requirements
      end

      private

      def validate_rebalance_order_rebalance_requirements
        validate_rebalance_order_status
      end

      def validate_rebalance_order_status
        return if rebalance_order.scheduled?

        raise RebalanceOrders::InvalidStatusError.new(rebalance_order:)
      end
    end
  end
end