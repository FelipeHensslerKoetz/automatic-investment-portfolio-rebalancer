FactoryBot.define do
  factory :investment_portfolio do
    user { create(:user) }
    name { "MyString" }
    description { "MyString" }
    currency { create(:currency) }
  end
end
