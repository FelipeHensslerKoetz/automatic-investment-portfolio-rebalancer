# frozen_string_literal: true

FactoryBot.define do
  factory :automatic_rebalance_option do
    kind { 'recurrence' }
    recurrence_days { 30 }
    start_date { Time.zone.today }
    investment_portfolio { create(:investment_portfolio) }
  end

  trait :recurrence do
    kind { 'recurrence' }
  end

  trait :deviation do
    kind { 'deviation' }
  end
end
