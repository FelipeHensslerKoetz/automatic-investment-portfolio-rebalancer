# frozen_string_literal: true

module RebalanceOrders
  class InvalidStatusError < StandardError
    attr_reader :rebalance_order

    def initialize(rebalance_order:)
      @rebalance_order = rebalance_order
      super("Expecting pending status for RebalanceOrder with id #{rebalance_order.id}, got #{rebalance_order.status} status.")
    end
  end
end
