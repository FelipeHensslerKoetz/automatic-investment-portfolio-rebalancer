class RemoveAveragePriceFromInvestmentPortfolioAsset < ActiveRecord::Migration[6.1]
  def change
    remove_column :investment_portfolio_assets, :average_price
  end

  def down
    add_column :investment_portfolio_assets, :average_price, :decimal
  end
end
