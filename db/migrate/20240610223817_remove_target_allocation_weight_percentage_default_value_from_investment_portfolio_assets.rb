class RemoveTargetAllocationWeightPercentageDefaultValueFromInvestmentPortfolioAssets < ActiveRecord::Migration[6.1]
  def change
    change_column_default :investment_portfolio_assets, :target_allocation_weight_percentage, nil
  end
end
