# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvestmentPortfolioAssetSerializer, type: :serializer do
  describe 'attributes' do
    it 'returns the correct attributes' do
      investment_portfolio_asset = build(:investment_portfolio_asset)
      serializer = described_class.new(investment_portfolio_asset)

      expect(serializer.attributes).to eq(
        asset_ticker_symbol: investment_portfolio_asset.asset.ticker_symbol,
        asset_id: investment_portfolio_asset.asset_id,
        quantity: investment_portfolio_asset.quantity,
        target_allocation_weight_percentage: investment_portfolio_asset.target_allocation_weight_percentage,
        target_variation_limit_percentage: investment_portfolio_asset.target_variation_limit_percentage
      )
    end
  end
end
