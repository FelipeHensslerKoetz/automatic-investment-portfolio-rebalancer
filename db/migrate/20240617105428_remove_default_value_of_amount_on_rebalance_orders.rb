class RemoveDefaultValueOfAmountOnRebalanceOrders < ActiveRecord::Migration[6.1]
  def change
    change_column_default :rebalance_orders, :amount, nil
  end
end
