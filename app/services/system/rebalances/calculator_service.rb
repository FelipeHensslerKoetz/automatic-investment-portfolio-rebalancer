# frozen_string_literal: true

module System
  module Rebalances
    class CalculatorService
      attr_reader :rebalance_order_id

      def self.call(rebalance_order_id:)
        new(rebalance_order_id:).call
      end

      def initialize(rebalance_order_id:)
        @rebalance_order_id = rebalance_order_id
      end

      def call
        Rebalances::ValidationService.call(rebalance_order_id:)
        calculate_rebalance
      rescue StandardError => e
        create_error_log(e)
      end

      private

      def rebalance_order
        @rebalance_order ||= RebalanceOrder.includes(:investment_portfolio).find_by(id: rebalance_order_id)
      end

      def investment_portfolio
        @investment_portfolio ||= rebalance_order.investment_portfolio
      end

      def current_investment_portfolio_state
        @current_investment_portfolio_state ||= compute_current_investment_portfolio_state
      end

      def projected_investment_portfolio_state_with_rebalance_actions
        @projected_investment_portfolio_state_with_rebalance_actions ||= System::Rebalances::ProjectedInvestmentPortfolioStateWithRebalanceActionsCalculatorService.call(
          current_investment_portfolio_state: current_investment_portfolio_state_result
        )
      end

      def calculate_rebalance
        rebalance_order.process!
        create_rebalance
        set_rebalance_order_success
        create_investment_portfolio_rebalance_notification_orders
      end

      def compute_current_investment_portfolio_state
        @investment_portfolio_projected_total_value = current_investment_portfolio_state_result[:investment_portfolio_projected_total_value]
        current_investment_portfolio_state_result[:current_investment_portfolio_state]
      end

      def current_investment_portfolio_state_result
        @current_investment_portfolio_state_result ||= System::Rebalances::CurrentInvestmentPortfolioStateCalculatorService.call(
          investment_portfolio:,
          amount: rebalance_order.amount,
          rebalance_kind: rebalance_order.kind
        )
      end

      def create_rebalance
        Rebalance.create!(rebalance_order:, current_investment_portfolio_state:, projected_investment_portfolio_state_with_rebalance_actions:, details:, recommended_actions:)
      end

      def details
        {
          investment_portfolio_id: investment_portfolio.id,
          investment_portfolio_projected_total_value: @investment_portfolio_projected_total_value,
          rebalance_order_amount: rebalance_order.amount,
          rebalance_order_kind: rebalance_order.kind
        }
      end

      def recommended_actions
        actions = { sell: [], buy: [] }

        current_investment_portfolio_state.each do |asset_details|
          next if asset_details[:quantity_adjustment].zero?

          if asset_details[:quantity_adjustment].positive?
            actions[:buy] << { ticker_symbol: asset_details[:ticker_symbol], quantity: asset_details[:quantity_adjustment] }
          else
            actions[:sell] << { ticker_symbol: asset_details[:ticker_symbol], quantity: asset_details[:quantity_adjustment].abs }
          end
        end

        actions
      end

      def set_rebalance_order_success
        rebalance_order.update(error_message: nil) if rebalance_order.error_message.present?
        rebalance_order.success!
      end

      def create_error_log(error)
        error_log = System::Logs::CreatorService.create_log(kind: :error, data: error_message(error))

        return if rebalance_order.blank?

        rebalance_order.process! if rebalance_order&.may_process?
        rebalance_order.fail! if rebalance_order&.may_fail?
        rebalance_order.update(error_message: error_log['data']['message'])
      end

      def error_message(error)
        {
          context: "#{self.class} - rebalance_order_id=#{rebalance_order_id}",
          message: "#{error.class}: #{error.message}",
          backtrace: error.backtrace
        }
      end

      def create_investment_portfolio_rebalance_notification_orders
        return unless investment_portfolio.investment_portfolio_rebalance_notification_options.any?

        investment_portfolio.investment_portfolio_rebalance_notification_options.each do |investment_portfolio_rebalance_notification_option|
          InvestmentPortfolioRebalanceNotificationOrder.create!(
            investment_portfolio:,
            investment_portfolio_rebalance_notification_option:,
            rebalance: rebalance_order.rebalance,
            rebalance_order:
          )
        end
      end
    end
  end
end
