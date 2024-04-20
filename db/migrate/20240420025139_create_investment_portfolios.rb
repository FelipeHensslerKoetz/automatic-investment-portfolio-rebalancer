class CreateInvestmentPortfolios < ActiveRecord::Migration[6.1]
  def change
    create_table :investment_portfolios do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :description
      t.references :currency, null: false, foreign_key: true

      t.timestamps
    end
  end
end
