# frozen_string_literal: true

class InvestmentPortfolioAssetSerializer < ActiveModel::Serializer
  attributes :asset_ticker_symbol, :asset_id, :quantity, :target_allocation_weight_percentage, :target_variation_limit_percentage

  def asset_ticker_symbol
    object.asset.ticker_symbol
  end
end
