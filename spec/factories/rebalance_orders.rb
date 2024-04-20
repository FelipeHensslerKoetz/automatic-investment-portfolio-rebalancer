FactoryBot.define do
  factory :rebalance_order do
    user { nil }
    investment_portfolio { nil }
    status { "MyString" }
    type { "" }
    amount { "9.99" }
    error_message { "MyString" }
    scheduled_at { "2024-04-20 00:03:13" }
  end
end
