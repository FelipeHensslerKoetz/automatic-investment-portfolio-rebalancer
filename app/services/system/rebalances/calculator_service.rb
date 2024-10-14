# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/MethodLength
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

      def investment_portfolio_assets
        @investment_portfolio_assets ||= investment_portfolio.investment_portfolio_assets
      end

      def before_state
        @before_state ||= compute_before_state
      end

      def after_state
        @after_state ||= Marshal.load(Marshal.dump(before_state)).map do |asset_details|
          asset_details[:quantity] = asset_details[:target_quantity]
          asset_details.merge(investment_portfolio_indicators(asset_details))
        end
      end

      def calculate_rebalance
        rebalance_order.process!
        create_rebalance
        set_rebalance_order_success
        create_investment_portfolio_rebalance_notification_orders
      end

      def compute_before_state
        state = investment_portfolio_assets.map do |investment_portfolio_asset|
          investment_portfolio_asset_details(investment_portfolio_asset)
        end

        @investment_portfolio_projected_total_value = compute_investment_portfolio_projected_total_value(state)

        compute_investment_portfolio_indicators(state)
      end

      def compute_investment_portfolio_projected_total_value(state)
        assets_sum = state.sum do |asset_details|
          asset_details[:price] * asset_details[:quantity]
        end

        case rebalance_order.kind
        when 'default'
          assets_sum
        when 'withdraw'
          final_sum = assets_sum - rebalance_order.amount

          check_invalid_withdraw_amount(assets_sum, final_sum)

          final_sum
        when 'deposit'
          assets_sum + rebalance_order.amount
        end
      end

      def investment_portfolio_asset_details(investment_portfolio_asset)
        asset = investment_portfolio_asset.asset
        newest_asset_price = AssetPrices::UpdatedAssetPriceService.call(asset:)
        price = compute_price_and_currency_parity_exchange_rate(newest_asset_price)

        {
          ticker_symbol: investment_portfolio_asset.asset.ticker_symbol,
          quantity: investment_portfolio_asset.quantity,
          target_allocation_weight_percentage: investment_portfolio_asset.target_allocation_weight_percentage,
          target_variation_limit_percentage: investment_portfolio_asset.target_variation_limit_percentage,
          price: price[:price],
          currency: Currency.default_currency,
          original_price: newest_asset_price.price,
          original_currency: newest_asset_price.currency,
          asset_price: newest_asset_price,
          currency_parity_exchange_rate: price[:currency_parity_exchange_rate]
        }
      end

      def compute_investment_portfolio_indicators(state)
        state.map { |asset_details| asset_details.merge(investment_portfolio_indicators(asset_details)) }
      end

      def compute_price_and_currency_parity_exchange_rate(asset_price)
        AssetPrices::ConvertParityService.call(asset_price:)
      end

      def investment_portfolio_indicators(asset_details)
        current_total_value = current_total_value(asset_details)
        current_allocation_weight_percentage = current_allocation_weight_percentage(current_total_value)
        current_deviation_percentage = current_deviation_percentage(asset_details, current_allocation_weight_percentage)
        target_total_value = target_total_value(asset_details)
        target_quantity = target_quantity(asset_details, target_total_value)
        quantity_adjustment = quantity_adjustment(asset_details, target_quantity)

        {
          current_total_value:, current_allocation_weight_percentage:, current_deviation_percentage:, target_total_value:,
          target_quantity:, quantity_adjustment:
        }
      end

      def current_total_value(asset_details)
        asset_details[:price] * asset_details[:quantity]
      end

      def current_allocation_weight_percentage(current_total_value)
        return 0.0 if @investment_portfolio_projected_total_value.zero?

        (current_total_value / @investment_portfolio_projected_total_value) * 100.0
      end

      def current_deviation_percentage(asset_details, current_allocation_weight_percentage)
        current_allocation_weight_percentage - asset_details[:target_allocation_weight_percentage]
      end

      def target_total_value(asset_details)
        (asset_details[:target_allocation_weight_percentage] / 100.0) * @investment_portfolio_projected_total_value
      end

      def target_quantity(asset_details, target_total_value)
        target_total_value / asset_details[:price]
      end

      def quantity_adjustment(asset_details, target_quantity)
        target_quantity - asset_details[:quantity]
      end

      def create_rebalance
        Rebalance.create!(rebalance_order:, before_state:, after_state:, details:, recommended_actions:)
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

        before_state.each do |asset_details|
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

      def check_invalid_withdraw_amount(assets_sum, final_sum)
        return unless final_sum.negative?

        raise RebalanceOrders::InvalidWithdrawAmountError,
              "Insufficient funds to withdraw #{rebalance_order.amount}, the max withdraw is #{assets_sum}."
      end

      def create_investment_portfolio_rebalance_notification_orders
        return unless investment_portfolio.investment_portfolio_rebalance_notification_options.any?

        investment_portfolio.investment_portfolio_rebalance_notification_options.each do |investment_portfolio_rebalance_notification_option|
          InvestmentPortfolioRebalanceNotificationOrder.create!(
            investment_portfolio: investment_portfolio,
            investment_portfolio_rebalance_notification_option: investment_portfolio_rebalance_notification_option,
            rebalance:  rebalance_order.rebalance,
            rebalance_order: rebalance_order
          )
        end
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/ClassLength
