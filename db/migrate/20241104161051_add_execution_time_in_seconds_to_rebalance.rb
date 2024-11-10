class AddExecutionTimeInSecondsToRebalance < ActiveRecord::Migration[6.1]
  def change
    add_column :rebalances, :execution_time_in_seconds, :decimal
  end

  def down
    remove_column :rebalances, :execution_time_in_seconds
  end
end
