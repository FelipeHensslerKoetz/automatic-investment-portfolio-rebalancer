# frozen_string_literal: true

require 'rails_helper'

RSpec.describe System::AssetPrices::ConvertParityService do
  subject(:price) { described_class.call(asset_price:) }

  let!(:brl_currency) { create(:currency, :brl) }
  let(:usd_currency) { create(:currency, :usd) }
  let(:petr4_asset) do
    create(:asset,
           ticker_symbol: 'PETR4',
           name: 'Petrobras')
  end

  context 'when convert is possible' do
    context 'when input_currency is different from output_currency' do
      context 'when only input to output currency parity is available' do
        let(:asset_price) do
          create(:asset_price,
                 :with_hg_brasil_stock_price_partner_resource,
                 asset: petr4_asset,
                 currency: usd_currency,
                 status: :updated)
        end

        let!(:currency_parity_exchange_rate) do
          create(:currency_parity_exchange_rate,
                 :with_hg_brasil_stock_price_partner_resource,
                 exchange_rate: 5,
                 currency_parity:,
                 status: :updated)
        end

        let(:currency_parity) { create(:currency_parity, currency_from: usd_currency, currency_to: brl_currency) }

        it 'returns the asset_price price converted to output_currency' do
          expect(price).to eq({ price: asset_price.price * 5, currency_parity_exchange_rate: })
        end
      end

      context 'when only output to input currency parity is available' do
        let(:asset_price) do
          create(:asset_price,
                 :with_hg_brasil_stock_price_partner_resource,
                 asset: petr4_asset,
                 currency: usd_currency,
                 status: :updated)
        end

        let!(:currency_parity_exchange_rate) do
          create(:currency_parity_exchange_rate,
                 :with_hg_brasil_stock_price_partner_resource,
                 exchange_rate: 0.20,
                 currency_parity:,
                 status: :updated)
        end

        let(:currency_parity) { create(:currency_parity, currency_from: brl_currency, currency_to: usd_currency) }

        it 'returns the asset_price price converted to output_currency' do
          expect(price).to eq({ price: asset_price.price / 0.20, currency_parity_exchange_rate: })
        end
      end

      context 'when both input to output currency parity and output to input currency parity are available' do
        let(:asset_price) do
          create(:asset_price,
                 :with_hg_brasil_stock_price_partner_resource,
                 asset: petr4_asset,
                 currency: usd_currency,
                 status: :updated)
        end

        let!(:usd_to_brl_currency_parity_exchange_rate) do
          create(:currency_parity_exchange_rate,
                 :with_hg_brasil_stock_price_partner_resource,
                 exchange_rate: 5,
                 currency_parity: currency_parity_input_to_output,
                 status: :updated)
        end

        let!(:brl_to_usd_currency_parity_exchange_rate) do
          create(:currency_parity_exchange_rate,
                 :with_hg_brasil_stock_price_partner_resource,
                 exchange_rate: 0.20,
                 currency_parity: currency_parity_output_to_input,
                 status: :updated)
        end

        let!(:currency_parity_input_to_output) { create(:currency_parity, currency_from: usd_currency, currency_to: brl_currency) }
        let!(:currency_parity_output_to_input) { create(:currency_parity, currency_from: brl_currency, currency_to: usd_currency) }

        it 'returns the asset_price price converted to output_currency' do
          expect(price).to eq({ price: asset_price.price * 5, currency_parity_exchange_rate: usd_to_brl_currency_parity_exchange_rate })
        end
      end
    end

    context 'when input_currency is the same as output_currency' do
      let(:asset_price) do
        create(:asset_price,
               :with_hg_brasil_stock_price_partner_resource,
               asset: petr4_asset,
               currency: brl_currency,
               status: :updated)
      end

      it 'returns the asset_price price' do
        expect(price).to eq({ price: asset_price.price, currency_parity_exchange_rate: nil })
      end
    end
  end

  context 'when convert is not possible' do
    context 'when asset_price is invalid' do
      let(:asset_price) { nil }

      it { expect { price }.to raise_error(ArgumentError) }
    end

    context 'whe asset_price status is not updated' do
      let(:asset_price) do
        create(:asset_price,
               :with_hg_brasil_stock_price_partner_resource,
               asset: petr4_asset,
               currency: brl_currency,
               status: :scheduled)
      end

      it { expect { price }.to raise_error(AssetPrices::OutdatedError) }
    end

    context 'when there are not at least one currency_parity_available' do
      let(:asset_price) do
        create(:asset_price,
               :with_hg_brasil_stock_price_partner_resource,
               asset: petr4_asset,
               currency: usd_currency,
               status: :updated)
      end

      it { expect { price }.to raise_error(CurrencyParities::MissingError) }
    end

    context 'when there are not at least one updated currency_parity_exchange_rate' do
      let(:asset_price) do
        create(:asset_price,
               :with_hg_brasil_stock_price_partner_resource,
               asset: petr4_asset,
               currency: usd_currency,
               status: :updated)
      end

      before do
        currency_parity = create(:currency_parity, currency_from: brl_currency, currency_to: usd_currency)
        create(:currency_parity_exchange_rate,
               :with_hg_brasil_stock_price_partner_resource,
               exchange_rate: 5.0,
               currency_parity:,
               status: :scheduled)
      end

      it { expect { price }.to raise_error(CurrencyParities::OutdatedError) }
    end
  end
end
