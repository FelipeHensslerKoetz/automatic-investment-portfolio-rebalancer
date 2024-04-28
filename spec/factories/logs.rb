# frozen_string_literal: true

FactoryBot.define do
  factory :log do
    data { { 'some' => 'data' } }

    trait :error do
      kind { :error }
    end

    trait :info do
      kind { :info }
    end
  end
end
