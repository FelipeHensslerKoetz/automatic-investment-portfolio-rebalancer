class AddNotNullToScheduledAtOnRebalanceOrders < ActiveRecord::Migration[6.1]
  def change
    change_column_null :rebalance_orders, :scheduled_at, false
  end
end
