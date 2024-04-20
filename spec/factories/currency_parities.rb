FactoryBot.define do
  factory :currency_parity do
    currency_from { create(:currency) }
    currency_to { create(:currency) }
  end
end
