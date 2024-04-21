# frozen_string_literal: true

FactoryBot.define do
  factory :log do
    type { Log::LOG_KINDS.sample }
    data { {} }
  end
end
