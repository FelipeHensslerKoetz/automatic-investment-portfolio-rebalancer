# frozen_string_literal: true

module System
  module Rebalances
    class ValidationService
      attr_reader :rebalance_order_id

      def initialize(rebalance_order_id:)
        @rebalance_order_id = rebalance_order_id
      end

      def self.call(rebalance_order_id:)
        new(rebalance_order_id:).call
      end

      def call
        validate_rebalance_requirements
        true
      end

      private

      def rebalance_order 
        @rebalance_order ||= RebalanceOrder.find(rebalance_order_id)
      end

      def investment_portfolio 
        @investment_portfolio ||= rebalance_order.investment_portfolio
      end

      def validate_rebalance_requirements
        System::Rebalances::RebalanceOrderValidationService.call(rebalance_order: rebalance_order)
        System::Rebalances::InvestmentPortfolioValidationService.call(investment_portfolio: investment_portfolio)
      end
    end
  end
end
