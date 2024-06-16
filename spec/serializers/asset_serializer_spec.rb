# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssetSerializer, type: :serializer do
  describe 'attributes' do
    it 'returns the correct attributes' do
      asset = build(:asset)
      serializer = described_class.new(asset)

      expect(serializer.attributes).to eq(
        id: asset.id,
        ticker_symbol: asset.ticker_symbol,
        name: asset.name,
        kind: asset.kind
      )
    end
  end
end
