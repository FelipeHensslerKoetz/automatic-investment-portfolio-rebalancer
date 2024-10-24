# frozen_string_literal: true

module System
  module Rebalances
    class CurrentInvestmentPortfolioStateCalculatorService
      attr_reader :investment_portfolio, :amount, :investment_portfolio_projected_total_value, :rebalance_kind

      def initialize(investment_portfolio:, amount:, rebalance_kind:)
        @investment_portfolio = investment_portfolio
        @amount = amount
        @investment_portfolio_projected_total_value = nil
        @investment_portfolio_assets_sum = nil
        @rebalance_kind = rebalance_kind
      end

      def self.call(investment_portfolio:, amount:, rebalance_kind:)
        new(investment_portfolio:, amount:, rebalance_kind:).call
      end

      def call
        @investment_portfolio_projected_total_value = compute_investment_portfolio_projected_total_value

        { current_investment_portfolio_state: current_investment_portfolio_state_with_indicators,
          investment_portfolio_projected_total_value: }
      end

      private

      def investment_portfolio_assets
        @investment_portfolio_assets ||= investment_portfolio.investment_portfolio_assets
      end

      def current_investment_portfolio_state
        @current_investment_portfolio_state ||= investment_portfolio_assets.map do |investment_portfolio_asset|
          investment_portfolio_asset_details(investment_portfolio_asset)
        end
      end

      def current_investment_portfolio_state_with_indicators
        @current_investment_portfolio_state_with_indicators ||= compute_investment_portfolio_indicators
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

      def compute_price_and_currency_parity_exchange_rate(asset_price)
        AssetPrices::ConvertParityService.call(asset_price:)
      end

      def compute_investment_portfolio_indicators
        if rebalance_kind == 'default'
          compute_investment_portfolio_default_indicators
        elsif rebalance_kind == 'contribution'
          compute_investment_portfolio_contribution_indicators
        end
      end

      def compute_investment_portfolio_default_indicators
        current_investment_portfolio_state.map do |asset_details|
          asset_details.merge(investment_portfolio_default_indicators(asset_details))
        end
      end

      def compute_investment_portfolio_contribution_indicators
        deficit_details = {
          total_deficit: 0,
          deficit_assets: [],
          amount_diff_to_total_deficit: 0
        }

        current_investment_portfolio_state.each do |asset_details|
          target_total_value = investment_portfolio_projected_total_value * (asset_details[:target_allocation_weight_percentage] / 100.0)
          current_total_value = asset_details[:price] * asset_details[:quantity]
          deficit = target_total_value - current_total_value

          if deficit.positive?
            deficit_details[:deficit_assets] << { ticker_symbol: asset_details[:ticker_symbol], deficit: }
            deficit_details[:total_deficit] += deficit
          end
        end

        deficit_details[:amount_diff_to_total_deficit] = amount - deficit_details[:total_deficit]

        deficit_details[:deficit_assets].map! do |deficit_asset|
          if deficit_details[:amount_diff_to_total_deficit].negative?
            deficit_asset.merge!({
                                   rebalance_value: ((deficit_asset[:deficit] / deficit_details[:total_deficit]) * amount)
                                 })
          else
            deficit_asset.merge!({
                                   rebalance_value: deficit_asset[:deficit]
                                 })
          end
        end

        current_investment_portfolio_state.map do |asset_details|
          deficit_asset = deficit_details[:deficit_assets].find do |deficit_asset|
            deficit_asset[:ticker_symbol] == asset_details[:ticker_symbol]
          end
          rebalance_value = deficit_asset&.dig(:rebalance_value) || 0
          current_total_value = current_total_value(asset_details)
          current_allocation_weight_percentage = current_allocation_weight_percentage(current_total_value)
          current_variation_percentage = current_variation_percentage(asset_details, current_allocation_weight_percentage)
          target_total_value = current_total_value + rebalance_value
          target_quantity = target_quantity(asset_details, target_total_value)
          quantity_adjustment = quantity_adjustment(asset_details, target_quantity)

          asset_details.merge({
                                current_total_value:,
                                current_allocation_weight_percentage:,
                                current_variation_percentage:,
                                target_total_value:,
                                target_quantity:,
                                quantity_adjustment:
                              })
        end
      end

      def investment_portfolio_assets_sum
        @investment_portfolio_assets_sum ||= current_investment_portfolio_state.sum do |asset_details|
          asset_details[:price] * asset_details[:quantity]
        end
      end

      def compute_investment_portfolio_projected_total_value
        final_sum = investment_portfolio_assets_sum + amount

        if final_sum.negative?
          raise RebalanceOrders::InvalidWithdrawAmountError,
                "Insufficient funds to withdraw #{amount.abs}, the max withdraw is #{investment_portfolio_assets_sum}."
        end

        final_sum
      end

      def investment_portfolio_default_indicators(asset_details)
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
        (current_total_value / investment_portfolio_assets_sum) * 100.0
      end

      def current_variation_percentage(asset_details, current_allocation_weight_percentage)
        100 * (current_allocation_weight_percentage - asset_details[:target_allocation_weight_percentage]) / asset_details[:target_allocation_weight_percentage]
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
