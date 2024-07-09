class AddAssetIdAndInvestmentPortfolioIdUniqueIndexOnInvestmentPortfolioAssets < ActiveRecord::Migration[6.1]
  def change
    add_index :investment_portfolio_assets, [:asset_id, :investment_portfolio_id], unique: true, name: 'asset_id_and_investment_portfolio_id_index'
  end
end
