class CreateInvestmentPortfolioAssets < ActiveRecord::Migration[6.1]
  def change
    create_table :investment_portfolio_assets do |t|
      t.references :asset, null: false, foreign_key: true
      t.references :investment_portfolio, null: false, foreign_key: true
      t.decimal :allocation_weight, null: false, default: 0.0
      t.decimal :quantity, null: false, default: 0.0
      t.decimal :deviation_percentage, null: false, default: 0.0

      t.timestamps
    end
  end
end
