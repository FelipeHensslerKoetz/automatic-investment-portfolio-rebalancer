class CreateAutomaticRebalanceOptions < ActiveRecord::Migration[6.1]
  def change
    create_table :automatic_rebalance_options do |t|
      t.references :investment_portfolio, null: false, foreign_key: true
      t.string :kind, null: false
      t.integer :recurrence_days
      t.date :start_date, null: false
      t.timestamps
    end
  end
end
