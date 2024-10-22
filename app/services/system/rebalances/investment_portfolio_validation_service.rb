module System 
  module Rebalances 
    class InvestmentPortfolioValidationService
      attr_reader :investment_portfolio

      def initialize(investment_portfolio:)
        @investment_portfolio = investment_portfolio
      end

      def self.call(investment_portfolio:)
        new(investment_portfolio: investment_portfolio).call
      end

      def call
        validate_investment_portfolio_rebalance_requirements
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

      def validate_investment_portfolio_rebalance_requirements
        validate_investment_portfolio_assets_count
        validate_investment_portfolio_total_allocation_weight
        validate_all_asset_prices_up_to_date
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

      def validate_all_asset_prices_up_to_date
        investment_portfolio_assets.each do |investment_portfolio_asset|
          AssetPrices::UpdatedAssetPriceService.call(asset: investment_portfolio_asset.asset)
        end
      end
    end
  end
end