# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssetPrices::ConvertParityService do
  subject(:price) { described_class.call(asset_price_id:, output_currency_id:) }

  let(:petr4_asset) do
    create(:asset,
           ticker_symbol: 'PETR4',
           name: 'Petrobras')
  end
  let(:brl_currency) { create(:currency, :brl) }
  let(:usd_currency) { create(:currency, :usd) }
  let(:btc_currency) { create(:currency, :btc) }

  context 'when asset price can be calculated' do
    let(:asset) { petr4_asset }
    let(:output_currency_id) { usd_currency.id }
    let(:asset_price_id) { asset_price.id }
    let(:asset_price) do
      create(:asset_price,
             :with_hg_brasil_stock_price_partner_resource,
             asset:,
             currency: brl_currency,
             price: 38.94,
             status: :updated)
    end

    before do
      currency_parity = create(:currency_parity,
                               currency_from: usd_currency,
                               currency_to: brl_currency)

      create(:currency_parity_exchange_rate,
             :with_hg_brasil_stock_price_partner_resource,
             currency_parity:,
             exchange_rate: 5.12)
    end

    it 'returns the asset price in the target currency' do
      response = price
      expect(response).to be_a(BigDecimal)
      expect(response.truncate(2)).to eq(7.6.to_d)
      expect(response * 5.12.to_d).to eq(38.94.to_d)
    end
  end

  context 'when asset price cannot be calculated' do
    context 'when asset param is invalid' do
      let(:asset_price_id) { nil }
      let(:output_currency_id) { usd_currency.id }

      it { expect { price }.to raise_error(ArgumentError) }
    end

    context 'when output_currency param is invalid' do
      let(:asset_price) { create(:asset_price, :with_hg_brasil_stock_price_partner_resource) }
      let(:asset_price_id) { asset_price.id }
      let(:output_currency_id) { nil }

      it { expect { price }.to raise_error(ArgumentError) }
    end

    context 'when there is no updated asset' do
      let(:asset_price) do
        create(:asset_price, :with_hg_brasil_stock_price_partner_resource, status: :scheduled, asset: petr4_asset,
                                                                           currency: brl_currency)
      end

      let(:asset_price_id) { asset_price.id }

      let(:output_currency_id) { usd_currency.id }

      before do
        currency_parity = create(:currency_parity,
                                 currency_from: usd_currency,
                                 currency_to: brl_currency)

        create(:currency_parity_exchange_rate,
               :with_hg_brasil_stock_price_partner_resource,
               currency_parity:,
               exchange_rate: 5.12)
      end

      it { expect { price }.to raise_error(AssetPriceOutdatedError) }
    end

    context 'when there are no currency parities' do
      let(:asset) { petr4_asset }
      let(:output_currency_id) { btc_currency.id }
      let(:asset_price_id) { asset_price.id }
      let!(:asset_price) do
        create(:asset_price,
               :with_hg_brasil_stock_price_partner_resource,
               asset:,
               currency: brl_currency,
               status: :updated)
      end

      it { expect { price }.to raise_error(CurrencyParityMissingError) }
    end

    context 'when there are no updated only currency parities' do
      let(:asset) { petr4_asset }
      let(:output_currency_id) { btc_currency.id }
      let(:asset_price_id) { asset_price.id }
      let!(:asset_price) do
        create(:asset_price,
               :with_hg_brasil_stock_price_partner_resource,
               asset:,
               currency: brl_currency,
               status: :updated)
      end

      let!(:currency_parity) do
        create(:currency_parity,
               currency_from: btc_currency,
               currency_to: brl_currency)
      end

      let!(:currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate, :with_hg_brasil_stock_price_partner_resource, :scheduled, currency_parity:)
      end

      it { expect { price }.to raise_error(CurrencyParityOutdatedError) }
    end
  end
end
