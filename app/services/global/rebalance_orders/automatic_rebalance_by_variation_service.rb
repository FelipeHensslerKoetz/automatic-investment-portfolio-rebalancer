# frozen_string_literal: true

module Global
  module RebalanceOrders
    class AutomaticRebalanceByVariationService
      attr_reader :automatic_rebalance_option

      def self.call(automatic_rebalance_option:)
        new(automatic_rebalance_option:).call
      end

      def initialize(automatic_rebalance_option:)
        @automatic_rebalance_option = automatic_rebalance_option
      end

      def call
        validate_automatic_rebalance_option
        check_automatic_rebalance_creation
      rescue StandardError => e
        create_error_log(e)
      end

      private

      def investment_portfolio
        @investment_portfolio ||= automatic_rebalance_option.investment_portfolio
      end

      def current_investment_portfolio_state
        @current_investment_portfolio_state ||= System::Rebalances::CurrentInvestmentPortfolioStateCalculatorService.call(
          investment_portfolio:,
          amount: automatic_rebalance_option.amount
        )
      end

      def validate_automatic_rebalance_option
        unless automatic_rebalance_option.is_a?(AutomaticRebalanceOption)
          raise ArgumentError,
                'automatic_rebalance_option is not an automatic rebalance option'
        end
        raise ArgumentError, 'automatic_rebalance_option does not have variation kind' unless automatic_rebalance_option.variation?
      end

      def check_automatic_rebalance_creation
        System::Rebalances::InvestmentPortfolioValidationService.call(investment_portfolio:)
        return unless investment_portfolio_with_variation?

        create_rebalance_order
      end

      def investment_portfolio_with_variation?
        current_investment_portfolio_state[:current_investment_portfolio_state].any? do |asset_details|
          asset_details[:current_variation_percentage].abs > asset_details[:target_variation_limit_percentage]
        end
      end

      def create_rebalance_order
        return if rebalance_order_already_created_today?

        RebalanceOrder.create!(
          investment_portfolio:,
          user: investment_portfolio.user,
          status: 'pending',
          kind: automatic_rebalance_option.rebalance_order_kind,
          amount: automatic_rebalance_option.amount,
          scheduled_at: Time.zone.today,
          created_by_system: true
        )
      end

      def create_error_log(error)
        Log.create!(
          kind: 'error',
          data: {
            context: "Global::RebalanceOrders::AutomaticRebalanceByVariationService - automatic_rebalance_option=#{automatic_rebalance_option&.id}",
            message: "#{error.class}: #{error.message}"
          }
        )
      end

      def rebalance_order_already_created_today?
        RebalanceOrder.exists?(
          investment_portfolio:,
          kind: automatic_rebalance_option.rebalance_order_kind,
          scheduled_at: Time.zone.today,
          created_by_system: true
        )
      end
    end
  end
end
