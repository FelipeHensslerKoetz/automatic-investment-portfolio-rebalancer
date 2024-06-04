class RenameAllocationWeightToTargetAllocationWeightOnInvestmentPortfolioAssets < ActiveRecord::Migration[6.1]
  def change
    rename_column :investment_portfolio_assets, :allocation_weight, :target_allocation_weight
  end
end
