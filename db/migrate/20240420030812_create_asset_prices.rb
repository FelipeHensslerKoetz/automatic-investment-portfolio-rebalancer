class CreateAssetPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :asset_prices do |t|
      t.references :asset, null: false, foreign_key: true
      t.references :partner_resource, null: false, foreign_key: true
      t.string :ticker_symbol, null: false
      t.references :currency, null: false, foreign_key: true
      t.decimal :price, null: false
      t.datetime :last_sync_at, null: false
      t.datetime :reference_date, null: false
      t.datetime :scheduled_at
      t.string :status, null: false
      t.string :error_message

      t.timestamps
    end
  end
end
