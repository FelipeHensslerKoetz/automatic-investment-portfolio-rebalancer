FactoryBot.define do
  factory :currency_parity_exchange_rate do
    currency_parity { nil }
    exchange_rate { "9.99" }
    last_sync_at { "2024-04-20 00:18:37" }
    reference_date { "2024-04-20 00:18:37" }
    partner_resource { nil }
    status { "MyString" }
    scheduled_at { "2024-04-20 00:18:37" }
    error_message { "MyString" }
  end
end
