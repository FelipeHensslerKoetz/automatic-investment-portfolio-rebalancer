# frozen_string_literal: true

FactoryBot.define do
  factory :investment_portfolio_asset do
    asset { create(:asset) }
    investment_portfolio { create(:investment_portfolio) }
    target_allocation_weight { rand(0.0..100.0) }
    quantity { rand(0..1000) }
    target_deviation_percentage { 0.0 }
  end
end
