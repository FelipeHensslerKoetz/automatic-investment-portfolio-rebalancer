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

      def investment_portfolio_total_allocation_weight
        @investment_portfolio_total_allocation_weight ||= investment_portfolio_assets.sum(:target_allocation_weight_percentage)
      end

      def investment_portfolio_assets_count
        @investment_portfolio_assets_count ||= investment_portfolio_assets.count
      end

      def investment_portfolio_assets
        @investment_portfolio_assets ||= investment_portfolio.investment_portfolio_assets
      end

      def rebalance_order
        @rebalance_order ||= RebalanceOrder.includes(:investment_portfolio).find_by(id: rebalance_order_id)
      end

      def investment_portfolio
        @investment_portfolio ||= rebalance_order.investment_portfolio
      end

      def validate_rebalance_requirements
        validate_rebalance_order_presence
        validate_rebalance_order_status
        validate_investment_portfolio_assets_count
        validate_investment_portfolio_total_allocation_weight
        validate_all_asset_prices_up_to_date
      end

      def validate_rebalance_order_presence
        return if rebalance_order.present?

        raise ArgumentError, "RebalanceOrder not found, id=#{rebalance_order_id}"
      end

      def validate_investment_portfolio_total_allocation_weight
        return unless invalid_investment_portfolio_total_allocation_weight?

        raise InvestmentPortfolios::InvalidTotalAllocationWeightError
          .new(investment_portfolio:, current_allocation_weight: investment_portfolio_total_allocation_weight)
      end

      def validate_investment_portfolio_assets_count
        return unless invalid_investment_portfolio_assets_count?

        raise InvestmentPortfolios::InvalidAssetsCountError.new(investment_portfolio:)
      end

      def invalid_investment_portfolio_total_allocation_weight?
        investment_portfolio_total_allocation_weight != 100
      end

      def invalid_investment_portfolio_assets_count?
        investment_portfolio_assets_count.zero?
      end

      def validate_rebalance_order_status
        return if rebalance_order.scheduled?

        raise RebalanceOrders::InvalidStatusError.new(rebalance_order:)
      end

      def validate_all_asset_prices_up_to_date
        investment_portfolio_assets.each do |investment_portfolio_asset|
          AssetPrices::UpdatedAssetPriceService.call(asset: investment_portfolio_asset.asset)
        end
      end
    end
  end
end
