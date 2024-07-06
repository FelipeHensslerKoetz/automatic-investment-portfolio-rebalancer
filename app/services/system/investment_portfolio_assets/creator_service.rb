# frozen_string_literal: true

module System
  module InvestmentPortfolioAssets
    class CreatorService
      attr_reader :investment_portfolio, :investment_portfolio_assets_attributes

      def initialize(investment_portfolio:, investment_portfolio_assets_attributes:)
        @investment_portfolio = investment_portfolio
        @investment_portfolio_assets_attributes = investment_portfolio_assets_attributes
      end

      def self.call(investment_portfolio:, investment_portfolio_assets_attributes:)
        new(investment_portfolio:, investment_portfolio_assets_attributes:).call
      end

      def call
        ActiveRecord::Base.transaction do
          investment_portfolio_assets_attributes.each do |investment_portfolio_asset_attributes|
            perform_asset_action(investment_portfolio_asset_attributes)
          end

          check_validations
        end

        investment_portfolio.reload.investment_portfolio_assets
      end

      private

      def perform_asset_action(investment_portfolio_asset_attributes)
        asset = fetch_asset(investment_portfolio_asset_attributes)
        investment_portfolio_asset = fetch_investment_portfolio_asset(asset)

        if destroy_action?(investment_portfolio_asset_attributes)
          destroy_asset(investment_portfolio_asset)
        else
          create_or_update_investment_portfolio_asset(investment_portfolio_asset, investment_portfolio_asset_attributes)
        end
      end

      def fetch_asset(investment_portfolio_asset_attributes)
        asset = Asset.find_by(id: investment_portfolio_asset_attributes['asset_id']) ||
                Asset.find_by(ticker_symbol: investment_portfolio_asset_attributes['asset_ticker_symbol']&.upcase) # TODO: rever busca de ativos custom

        raise ActiveRecord::RecordNotFound, 'Asset not found' if asset.blank?
        raise ActiveRecord::RecordNotFound, 'Asset not found' if asset.user != investment_portfolio.user && asset.custom?

        asset
      end

      def destroy_asset(investment_portfolio_asset)
        return unless investment_portfolio_asset.persisted?

        investment_portfolio_asset.destroy!
      end

      def create_or_update_investment_portfolio_asset(investment_portfolio_asset, investment_portfolio_asset_attributes)
        investment_portfolio_asset.assign_attributes(
          quantity: investment_portfolio_asset_attributes['quantity'],
          target_allocation_weight_percentage: investment_portfolio_asset_attributes['target_allocation_weight_percentage'],
          target_variation_limit_percentage: investment_portfolio_asset_attributes['target_variation_limit_percentage']
        )
        investment_portfolio_asset.save!
      end

      def fetch_investment_portfolio_asset(asset)
        investment_portfolio.investment_portfolio_assets.find_or_initialize_by(asset:)
      end

      def destroy_action?(investment_portfolio_asset_attributes)
        ActiveModel::Type::Boolean.new.cast(investment_portfolio_asset_attributes['_destroy'])
      end

      def invalid_investment_portfolio_total_allocation_weight?
        investment_portfolio_total_allocation_weight != 100
      end

      def investment_portfolio_total_allocation_weight
        @investment_portfolio_total_allocation_weight ||= investment_portfolio
                                                          .investment_portfolio_assets
                                                          .sum(:target_allocation_weight_percentage)
      end

      def validate_investment_portfolio_total_allocation_weight
        return unless invalid_investment_portfolio_total_allocation_weight?

        raise InvestmentPortfolios::InvalidTotalAllocationWeightError.new(investment_portfolio:,
                                                                          current_allocation_weight:
                                                                          investment_portfolio_total_allocation_weight)
      end

      def validate_rebalance_order_in_progress
        return unless RebalanceOrder.processing.exists?(investment_portfolio:)

        raise InvestmentPortfolios::RebalanceOrderInProgressError.new(investment_portfolio:)
      end

      def check_validations
        validate_investment_portfolio_total_allocation_weight
        validate_rebalance_order_in_progress
      end
    end
  end
end
