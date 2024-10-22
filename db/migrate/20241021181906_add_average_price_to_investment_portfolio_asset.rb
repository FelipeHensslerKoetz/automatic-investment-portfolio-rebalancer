class AddAveragePriceToInvestmentPortfolioAsset < ActiveRecord::Migration[6.1]
  def change
    add_column :investment_portfolio_assets, :average_price, :decimal, null: true, default: nil
  end

  def down
    remove_column :investment_portfolio_assets, :average_price
  end
end
