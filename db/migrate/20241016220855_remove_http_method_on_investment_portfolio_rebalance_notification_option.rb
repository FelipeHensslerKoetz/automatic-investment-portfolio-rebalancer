class RemoveHttpMethodOnInvestmentPortfolioRebalanceNotificationOption < ActiveRecord::Migration[6.1]
  def change
    remove_column :investment_portfolio_rebalance_notification_options, :http_method, :string
  end
end
