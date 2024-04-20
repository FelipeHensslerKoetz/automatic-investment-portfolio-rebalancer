class CreateCurrencies < ActiveRecord::Migration[6.1]
  def change
    create_table :currencies do |t|
      t.string :name, null: false
      t.string :code, null: false

      t.timestamps
    end

    add_index :currencies, :code, unique: true
  end
end
