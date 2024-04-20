class CreateRebalances < ActiveRecord::Migration[6.1]
  def change
    create_table :rebalances do |t|
      t.references :rebalance_order, null: false, foreign_key: true
      t.jsonb :before_state, null: false
      t.jsonb :after_state, null: false
      t.jsonb :details, null: false
      t.jsonb :recommended_actions, null: false
      t.string :status, null: false
      t.string :error_message

      t.timestamps
    end
  end
end
