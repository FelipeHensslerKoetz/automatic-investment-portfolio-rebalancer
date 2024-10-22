class AddAmountToAutomaticRebalanceOption < ActiveRecord::Migration[6.1]
  def change
    add_column :automatic_rebalance_options, :amount, :decimal, null: false, default: 0
  end

  def down
    remove_column :automatic_rebalance_options, :amount
  end
end
