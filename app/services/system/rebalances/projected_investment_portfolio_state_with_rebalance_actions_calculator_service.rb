module System 
  module Rebalances 
    class ProjectedInvestmentPortfolioStateWithRebalanceActionsCalculatorService
      attr_reader :current_investment_portfolio_state, :investment_portfolio_projected_total_value, :projected_investment_portfolio

      def initialize(current_investment_portfolio_state:)
        @current_investment_portfolio_state = current_investment_portfolio_state
        @investment_portfolio_projected_total_value = current_investment_portfolio_state[:investment_portfolio_projected_total_value]
        @projected_investment_portfolio = Marshal.load(Marshal.dump(current_investment_portfolio_state))
      end

      def self.call(current_investment_portfolio_state:)
        new(current_investment_portfolio_state: current_investment_portfolio_state).call
      end

      def call
        projected_investment_portfolio[:current_investment_portfolio_state].each do |asset_details|
          asset_details[:quantity] = asset_details[:target_quantity]
        end

        projected_investment_portfolio[:current_investment_portfolio_state].map do |asset_details|
          asset_details.merge(investment_portfolio_indicators(asset_details))
        end
      end

      private 

      def investment_portfolio_assets_sum
        @investment_portfolio_assets_sum ||= projected_investment_portfolio[:current_investment_portfolio_state].sum { |asset_details| asset_details[:price] * asset_details[:quantity] }
      end

      def investment_portfolio_indicators(asset_details)
        current_total_value = current_total_value(asset_details)
        current_allocation_weight_percentage = current_allocation_weight_percentage(current_total_value)
        current_variation_percentage = current_variation_percentage(asset_details, current_allocation_weight_percentage)
        target_total_value = target_total_value(asset_details)
        target_quantity = target_quantity(asset_details, target_total_value)
        quantity_adjustment = quantity_adjustment(asset_details, target_quantity)

        {
          current_total_value:, current_allocation_weight_percentage:, current_variation_percentage:, target_total_value:,
          target_quantity:, quantity_adjustment:
        }
      end

      def current_total_value(asset_details)
        asset_details[:price] * asset_details[:quantity]
      end

      def current_allocation_weight_percentage(current_total_value)
        return 0.0 if investment_portfolio_projected_total_value.zero?

        (current_total_value / investment_portfolio_assets_sum) * 100.0
      end

      def current_variation_percentage(asset_details, current_allocation_weight_percentage)
        100 * ((current_allocation_weight_percentage - asset_details[:target_allocation_weight_percentage]) / asset_details[:target_allocation_weight_percentage])
      end

      def target_total_value(asset_details)
        (asset_details[:target_allocation_weight_percentage] / 100.0) * investment_portfolio_projected_total_value
      end

      def target_quantity(asset_details, target_total_value)
        target_total_value / asset_details[:price]
      end

      def quantity_adjustment(asset_details, target_quantity)
        target_quantity - asset_details[:quantity]
      end
    end
  end
end