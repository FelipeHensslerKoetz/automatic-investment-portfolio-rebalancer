# frozen_string_literal: true

FactoryBot.define do
  factory :customer_support_item_message do
    customer_support_item { create(:customer_support_item) }
    user { create(:user) }
    message { 'message' }
  end
end
