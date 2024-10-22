class AddRebalanceOrderKindOnAutomaticRebalanceOption < ActiveRecord::Migration[6.1]
  def change
    add_column :automatic_rebalance_options, :rebalance_order_kind, :string, null: false, default: 'default'
  end

  def down 
    remove_column :automatic_rebalance_options, :rebalance_order_kind
  end
end
