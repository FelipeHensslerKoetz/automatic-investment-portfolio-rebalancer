class CreateAssets < ActiveRecord::Migration[6.1]
  def change
    create_table :assets do |t|
      t.string :ticker_symbol, null: false
      t.string :name, null: false
      t.string :kind
      t.boolean :custom, default: false, null: false
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end

    add_index :assets, :ticker_symbol, unique: true
  end
end
