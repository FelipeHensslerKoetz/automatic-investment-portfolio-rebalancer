class RemoveStatusAndErrorMessageFromRebalances < ActiveRecord::Migration[6.1]
  def change
    remove_column :rebalances, :status, :string
    remove_column :rebalances, :error_message, :string
  end
end
