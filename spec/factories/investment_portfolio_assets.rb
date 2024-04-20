FactoryBot.define do
  factory :investment_portfolio_asset do
    asset { create(:asset) }
    investment_portfolio { create(:investment_portfolio) }
    allocation_weight { rand(0.0..100.0) }
    quantity { rand(0..1000) }
    deviation_percentage { 0.0 }
  end
end
