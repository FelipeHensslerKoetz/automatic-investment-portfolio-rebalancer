class AddTargetVariationLimitPercentageOnInvestmentPortfolioAssets < ActiveRecord::Migration[6.1]
  def change
    add_column :investment_portfolio_assets, :target_variation_limit_percentage, :decimal, null: true
  end
end
