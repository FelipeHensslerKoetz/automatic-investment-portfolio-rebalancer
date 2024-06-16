class ChangeScheduleAtFromDateTimeToDateOnRebalanceOrders < ActiveRecord::Migration[6.1]
  def change
    change_column :rebalance_orders, :scheduled_at, :date
  end
end
