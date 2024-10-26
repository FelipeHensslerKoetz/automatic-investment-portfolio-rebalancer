class RemoveBodyFromInvestmentPortfolioRebalanceNotificationOption < ActiveRecord::Migration[6.1]
  def change
    remove_column :investment_portfolio_rebalance_notification_options, :body, :text
  end

  def down
    add_column :investment_portfolio_rebalance_notification_options, :body, :text
  end
end
