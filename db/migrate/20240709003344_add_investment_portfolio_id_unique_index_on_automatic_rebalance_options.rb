class AddInvestmentPortfolioIdUniqueIndexOnAutomaticRebalanceOptions < ActiveRecord::Migration[6.1]
  def change
    remove_index :automatic_rebalance_options, :investment_portfolio_id

    add_index :automatic_rebalance_options, :investment_portfolio_id, unique: true
  end
end
