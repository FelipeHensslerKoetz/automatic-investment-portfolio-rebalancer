FactoryBot.define do
  factory :automatic_rebalance_option do
    kind { "MyString" }
    recurrence_days { 1 }
    start_date { "2024-06-16" }
  end
end
