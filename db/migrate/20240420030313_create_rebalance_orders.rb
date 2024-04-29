class CreateRebalanceOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :rebalance_orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :investment_portfolio, null: false, foreign_key: true
      t.string :status, null: false
      t.string :kind, null: false
      t.decimal :amount, null: false, default: 0.0
      t.string :error_message
      t.datetime :scheduled_at, null: false

      t.timestamps
    end
  end
end
