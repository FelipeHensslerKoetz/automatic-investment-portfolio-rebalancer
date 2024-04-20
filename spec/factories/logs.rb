FactoryBot.define do
  factory :log do
    type { Log::LOG_TYPES.sample }
    data { {} }
  end
end
