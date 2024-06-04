class RenameTargetAllocationWeightToTargetAllocationWeightPercentageOnInvestmentPortfolioAssets < ActiveRecord::Migration[6.1]
  def change
    rename_column :investment_portfolio_assets, :target_allocation_weight, :target_allocation_weight_percentage
  end
end
