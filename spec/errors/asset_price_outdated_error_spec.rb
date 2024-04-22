# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssetPriceOutdatedError do
  subject(:error) { described_class.new(asset_price:) }

  let(:asset_price) { create(:asset_price, :with_hg_brasil_stock_price_partner_resource) }

  it 'inherits from StandardError' do
    expect(error).to be_a(StandardError)
  end

  it 'has a message' do
    expect(error.message).to eq("AssetPrice with id: #{asset_price.id} is outdated.")
  end

  it 'has an asset_price attribute' do
    expect(error.asset_price).to eq(asset_price)
  end
end
