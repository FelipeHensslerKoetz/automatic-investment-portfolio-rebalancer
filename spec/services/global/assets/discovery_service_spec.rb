# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Global::Assets::DiscoveryService do
  subject(:global_discovery) { described_class.new(keywords:) }

  before do
    create(:partner_resource, :hg_brasil_stock_price)
    create(:partner_resource, :br_api_quotation)
    create(:currency, code: 'BRL', name: 'Brazilian Real')
    create(:currency, code: 'USD', name: 'United States Dollar')
  end

  context 'when assets were found in many partner resources' do
    let(:keywords) { 'PETR4' }

    it 'creates a the asset with many asset prices' do
      VCR.use_cassette('global_discovery/multiple_partner_resource_discovery') do
        assets = global_discovery.call

        expect(assets.count).to eq(1)
        expect(assets.first.asset_prices.count).to eq(2)
        expect(assets.first.asset_prices.map { |ap| ap.partner_resource.slug }).to match_array(%w[hg_brasil_stock_price br_api_quotation])
      end
    end
  end

  context 'when no assets were not found' do
    let(:keywords) { 'NOT_FOUND' }

    it 'does not create any asset' do
      VCR.use_cassette('global_discovery/not_found') do
        assets = global_discovery.call

        expect(assets).to eq([])
        expect(Asset.count).to eq(0)
        expect(AssetPrice.count).to eq(0)
      end
    end
  end
end
