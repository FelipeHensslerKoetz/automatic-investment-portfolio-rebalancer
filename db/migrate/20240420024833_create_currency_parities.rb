class CreateCurrencyParities < ActiveRecord::Migration[6.1]
  def change
    create_table :currency_parities do |t|
      t.references :currency_from, null: false, foreign_key: { to_table: :currencies}
      t.references :currency_to, null: false, foreign_key: { to_table: :currencies }

      t.timestamps
    end
  end
end
