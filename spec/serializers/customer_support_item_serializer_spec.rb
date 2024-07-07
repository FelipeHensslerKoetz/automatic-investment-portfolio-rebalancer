# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomerSupportItemSerializer do
  describe 'attributes' do
    it 'has id, title, description, status' do
      customer_support_item = create(:customer_support_item)
      serializer = described_class.new(customer_support_item)
      expect(serializer.as_json.keys).to match_array(%i[id title description status])
    end
  end
end
