# frozen_string_literal: true

FactoryBot.define do
  factory :customer_support_item do
    user { create(:user) }
    title { 'tile' }
    description { 'description' }
    status { 'opened' }
  end
end
