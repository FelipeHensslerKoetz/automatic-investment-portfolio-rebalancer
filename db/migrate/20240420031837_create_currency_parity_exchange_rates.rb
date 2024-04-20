class CreateCurrencyParityExchangeRates < ActiveRecord::Migration[6.1]
  def change
    create_table :currency_parity_exchange_rates do |t|
      t.references :currency_parity, null: false, foreign_key: true
      t.decimal :exchange_rate, precision: 10, scale: 2, null: false
      t.datetime :last_sync_at, null: false
      t.datetime :reference_date, null: false
      t.references :partner_resource, null: false, foreign_key: true
      t.string :status, null: false
      t.datetime :scheduled_at
      t.string :error_message

      t.timestamps
    end
  end
end
