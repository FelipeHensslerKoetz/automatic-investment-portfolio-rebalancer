FactoryBot.define do
  factory :investment_portfolio_rebalance_notification_option do
    investment_portfolio { create(:investment_portfolio) }
    name { "Notification Option" }

    trait :webhook do
      kind { "webhook" }
      url { "http://example.com" }
      header { { 'Content-Type' => 'application/json' } }
      body { { 'key' => 'value' } }
    end

    trait :email do
      kind { "email" }
      email { Faker::Internet.email }
    end
  end
end
