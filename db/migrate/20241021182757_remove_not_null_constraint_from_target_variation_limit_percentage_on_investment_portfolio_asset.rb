class RemoveNotNullConstraintFromTargetVariationLimitPercentageOnInvestmentPortfolioAsset < ActiveRecord::Migration[6.1]
  def change
    change_column_null :investment_portfolio_assets, :target_variation_limit_percentage, true
  end

  def down
    change_column_null :investment_portfolio_assets, :target_variation_limit_percentage, false
  end
end
