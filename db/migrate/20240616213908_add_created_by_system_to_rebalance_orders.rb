class AddCreatedBySystemToRebalanceOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :rebalance_orders, :created_by_system, :boolean, default: false
  end
end
