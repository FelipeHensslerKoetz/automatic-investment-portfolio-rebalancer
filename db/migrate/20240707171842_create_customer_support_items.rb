class CreateCustomerSupportItems < ActiveRecord::Migration[6.1]
  def change
    create_table :customer_support_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :description, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
