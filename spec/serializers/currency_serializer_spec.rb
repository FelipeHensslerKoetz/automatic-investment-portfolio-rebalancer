# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrencySerializer, type: :serializer do
  describe 'attributes' do
    it 'returns the correct attributes' do
      currency = build(:currency)
      serializer = described_class.new(currency)

      expect(serializer.attributes).to eq(
        id: currency.id,
        name: currency.name,
        code: currency.code
      )
    end
  end
end
