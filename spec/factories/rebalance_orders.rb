# frozen_string_literal: true

FactoryBot.define do
  factory :rebalance_order do
    user { create(:user) }
    investment_portfolio { create(:investment_portfolio) }
    type { 'default' }
    scheduled_at { Time.zone.now }

    trait :scheduled do
      status { 'scheduled' }
    end

    trait :processing do
      status { 'processing' }
    end

    trait :finished do
      status { 'finished' }
    end

    trait :failed do
      status { 'failed' }
    end
  end
end
