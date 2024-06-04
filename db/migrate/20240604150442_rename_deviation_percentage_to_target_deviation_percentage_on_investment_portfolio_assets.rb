class RenameDeviationPercentageToTargetDeviationPercentageOnInvestmentPortfolioAssets < ActiveRecord::Migration[6.1]
  def change
    rename_column :investment_portfolio_assets, :deviation_percentage, :target_deviation_percentage
  end
end
