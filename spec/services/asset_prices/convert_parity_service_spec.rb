# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssetPrices::ConvertParityService do
  subject(:price) { described_class.call(asset_price:, output_currency:) }

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
    let(:output_currency) { usd_currency }
    let(:asset_price) do
      create(:asset_price,
             :with_hg_brasil_stock_price_partner_resource,
             asset:,
             currency: brl_currency,
             price: 40.0,
             status: :updated)
    end

    context 'when only input to output currency parity is available' do
      before do
        currency_parity = create(:currency_parity, currency_from: usd_currency, currency_to: brl_currency)

        create(:currency_parity_exchange_rate,
               :with_hg_brasil_stock_price_partner_resource,
               currency_parity:,
               exchange_rate: 5.0)

        another_currency_parity = create(:currency_parity, currency_from: brl_currency, currency_to: usd_currency)

        create(:currency_parity_exchange_rate,
               :with_hg_brasil_stock_price_partner_resource,
               currency_parity: another_currency_parity,
               exchange_rate: 0.2)
      end

      it 'returns the asset price in the target currency' do
        response = price

        expect(response[:price]).to be_a(BigDecimal)
        expect(response[:price].truncate(2)).to eq(8.0.to_d)
        expect(response[:price] * 5.0.to_d).to eq(40.0.to_d)
        expect(response[:currency_parity_exchange_rate]).to be_a(CurrencyParityExchangeRate)
      end
    end

    context 'when only output to input currency parity is available' do
      let(:currency_parity) do
        create(:currency_parity,
               currency_from: usd_currency,
               currency_to: brl_currency)
      end

      let!(:currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate,
               :with_hg_brasil_stock_price_partner_resource,
               currency_parity:,
               exchange_rate: 5.0)
      end

      it 'returns the asset price in the target currency' do
        response = price

        expect(response[:price]).to be_a(BigDecimal)
        expect(response[:price].truncate(2)).to eq(8.0.to_d)
        expect(response[:price] * 5.0.to_d).to eq(40.0.to_d)
        expect(response[:currency_parity_exchange_rate]).to eq(currency_parity_exchange_rate)
      end
    end

    context 'when both input to output currency parity and output to input currency parity are available' do
      let(:currency_parity) do
        create(:currency_parity,
               currency_from: brl_currency,
               currency_to: usd_currency)
      end

      let!(:currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate,
               :with_hg_brasil_stock_price_partner_resource,
               currency_parity:,
               exchange_rate: 0.2)
      end

      it 'returns the asset price in the target currency' do
        response = price
        expect(response[:price]).to be_a(BigDecimal)
        expect(response[:price].truncate(2)).to eq(8.0.to_d)
        expect(response[:price] * 5.0.to_d).to eq(40.0.to_d)
        expect(response[:currency_parity_exchange_rate]).to eq(currency_parity_exchange_rate)
      end
    end

    context 'when output currency is the same as the asset price currency' do
      let(:output_currency) { brl_currency }

      it 'returns the asset price in the target currency' do
        response = price
        expect(response[:price]).to be_a(BigDecimal)
        expect(response[:price].truncate(2)).to eq(40.0.to_d)
        expect(response[:currency_parity_exchange_rate]).to be_nil
      end
    end
  end

  context 'when asset price cannot be calculated' do
    context 'when asset param is invalid' do
      let(:asset_price) { nil }
      let(:output_currency) { usd_currency }

      it { expect { price }.to raise_error(ArgumentError) }
    end

    context 'when output_currency param is invalid' do
      let(:asset_price) { create(:asset_price, :with_hg_brasil_stock_price_partner_resource) }
      let(:output_currency) { nil }

      it { expect { price }.to raise_error(ArgumentError) }
    end

    context 'when the asset_price status is different from updated' do
      let(:asset_price) do
        create(:asset_price, :with_hg_brasil_stock_price_partner_resource, status: :scheduled, asset: petr4_asset,
                                                                           currency: brl_currency)
      end

      let(:output_currency) { usd_currency }

      before do
        currency_parity = create(:currency_parity,
                                 currency_from: usd_currency,
                                 currency_to: brl_currency)

        create(:currency_parity_exchange_rate,
               :with_hg_brasil_stock_price_partner_resource,
               currency_parity:,
               exchange_rate: 5.12)
      end

      it { expect { price }.to raise_error(AssetPrices::OutdatedError) }
    end

    context 'when there are no currency parities' do
      let(:asset) { petr4_asset }
      let(:output_currency) { btc_currency }
      let!(:asset_price) do
        create(:asset_price,
               :with_hg_brasil_stock_price_partner_resource,
               asset:,
               currency: brl_currency,
               status: :updated)
      end

      it { expect { price }.to raise_error(CurrencyParities::MissingError) }
    end

    context 'when there are no updated currency parities' do
      let(:asset) { petr4_asset }
      let(:output_currency) { btc_currency }
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

      it { expect { price }.to raise_error(CurrencyParities::OutdatedError) }
    end
  end
end
