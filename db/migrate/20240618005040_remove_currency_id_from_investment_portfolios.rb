class RemoveCurrencyIdFromInvestmentPortfolios < ActiveRecord::Migration[6.1]
  def change
    remove_column :investment_portfolios, :currency_id, :bigint
  end
end
