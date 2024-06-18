# frozen_string_literal: true

FactoryBot.define do
  factory :investment_portfolio do
    user { create(:user) }
    name { 'My stocks' }
    description { 'Stocks based portfolio' }
  end
end
