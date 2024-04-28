# frozen_string_literal: true

FactoryBot.define do
  factory :rebalance_order do
    user { create(:user) }
    investment_portfolio { create(:investment_portfolio) }
    kind { 'default' }
    scheduled_at { Time.zone.now }

    trait :pending do
      status { 'pending' }
    end

    trait :scheduled do
      status { 'scheduled' }
    end

    trait :processing do
      status { 'processing' }
    end

    trait :succeed do
      status { 'succeed' }
    end

    trait :failed do
      status { 'failed' }
    end
  end
end
