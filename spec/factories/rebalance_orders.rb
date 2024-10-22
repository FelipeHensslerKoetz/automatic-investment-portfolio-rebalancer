# frozen_string_literal: true

FactoryBot.define do
  factory :rebalance_order do
    user { create(:user) }
    investment_portfolio { create(:investment_portfolio) }
    scheduled_at { Time.zone.today }
    amount { nil }

    trait :default do
      kind { 'default' }
    end
    
    trait :average_price do 
      kind { 'average_price' }
    end

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
