# frozen_string_literal: true

module Global
  module RebalanceOrders
    class AutomaticRebalanceByDeviationService
      attr_reader :automatic_rebalance_option

      def self.call(automatic_rebalance_option:)
        new(automatic_rebalance_option:).call
      end

      def initialize(automatic_rebalance_option:)
        @automatic_rebalance_option = automatic_rebalance_option
      end

      def call; end
    end
  end
end
