class CreateCustomerSupportItemMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :customer_support_item_messages do |t|
      t.bigint :customer_support_item_id, null: false
      t.references :user, null: false, foreign_key: true
      t.string :message, null: false

      t.timestamps
    end

    add_foreign_key :customer_support_item_messages, :customer_support_items, column: :customer_support_item_id
    add_index :customer_support_item_messages, :customer_support_item_id, name: 'idx_customer_support_item_messages_on_customer_support_item_id'
  end
end
