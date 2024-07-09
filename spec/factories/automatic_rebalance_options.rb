# frozen_string_literal: true

FactoryBot.define do
  factory :automatic_rebalance_option do
    kind { 'recurrence' }
    recurrence_days { 30 }
    start_date { '2024-06-16' }
  end
end
