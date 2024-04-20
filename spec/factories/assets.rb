FactoryBot.define do
  factory :asset do
    ticker_symbol { "MyString" }
    name { "MyString" }
    kind { "MyString" }
    custom { false }
    user { nil }
  end
end
