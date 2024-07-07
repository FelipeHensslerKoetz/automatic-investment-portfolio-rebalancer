# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomerSupportItemMessageSerializer, type: :serializer do
  describe 'attributes' do
    it 'returns the correct attributes' do
      customer_support_item_message = build(:customer_support_item_message)
      serializer = described_class.new(customer_support_item_message)

      expect(serializer.attributes).to eq(
        id: customer_support_item_message.id,
        message: customer_support_item_message.message
      )
    end
  end
end
