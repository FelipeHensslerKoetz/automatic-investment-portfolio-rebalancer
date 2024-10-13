class CreateInvestmentPortfolioRebalanceNotificationOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :investment_portfolio_rebalance_notification_orders do |t|
      t.references :investment_portfolio, null: false, foreign_key: true, index: { name: 'index_ip_on_iprnor_id' }
      t.references :investment_portfolio_rebalance_notification_option, null: false, foreign_key: true, index: { name: 'index_iprno_on_iprnor_id'}
      t.references :rebalance, null: false, foreign_key: true, index: { name: 'index_rebalance_on_iprnor_id' }
      t.references :rebalance_order, null: false, foreign_key: true, index: { name: 'index_rebalance_order_on_iprnor_id' }
      t.string :error_message
      t.string :payload
      t.string :status
      t.integer :retry_count, default: 0

      t.timestamps
    end
  end
end
