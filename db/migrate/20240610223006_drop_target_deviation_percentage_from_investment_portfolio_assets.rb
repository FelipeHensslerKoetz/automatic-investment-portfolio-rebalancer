class DropTargetDeviationPercentageFromInvestmentPortfolioAssets < ActiveRecord::Migration[6.1]
  def change
    remove_column :investment_portfolio_assets, :target_deviation_percentage, :decimal
  end
end
