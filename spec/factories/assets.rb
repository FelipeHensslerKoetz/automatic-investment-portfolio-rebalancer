# frozen_string_literal: true

FactoryBot.define do
  factory :asset do
    ticker_symbol { 5.times.map { ('A'..'Z').to_a.sample }.join }
    name { Faker::Company.name }
    kind { Asset::ASSET_KINDS.sample }
    custom { false }
    user { nil }

    trait :custom do
      custom { true }
    end
  end
end
