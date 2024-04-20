FactoryBot.define do
  factory :asset_price do
    asset { nil }
    partner_resource { "" }
    ticker_symbol { "MyString" }
    currency { nil }
    price { "9.99" }
    last_sync_at { "2024-04-20 00:08:12" }
    reference_date { "2024-04-20 00:08:12" }
    scheduled_at { "2024-04-20 00:08:12" }
    status { "MyString" }
    error_message { "MyString" }
  end
end
