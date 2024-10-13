class CreateInvestmentPortfolioRebalanceNotificationOptions < ActiveRecord::Migration[6.1]
  def change
    create_table :investment_portfolio_rebalance_notification_options do |t|
      t.string :kind, null: false
      t.references :investment_portfolio, null: false, foreign_key: true, index: { name: 'index_iprno_on_ip_id' }
      t.string :name, null: false
      t.string :url
      t.string :http_method
      t.jsonb :header
      t.jsonb :body
      t.string :email

      t.timestamps
    end
  end
end
