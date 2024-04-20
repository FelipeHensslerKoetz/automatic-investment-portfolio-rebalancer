FactoryBot.define do
  factory :investment_portfolio do
    user { create(:user) }
    name { 'My stocks' }
    description { 'Stocks based portfolio' }
    currency { create(:currency) }
  end
end
