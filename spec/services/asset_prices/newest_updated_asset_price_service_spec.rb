# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssetPrices::NewestUpdatedAssetPriceService do
  subject(:newest_updated_asset_price_service) { described_class.call(asset:, currency:) }

  describe '.call' do
    context 'when there is a updated asset price' do
      let(:currency) { create(:currency, :brl) }
      let(:another_currency) { create(:currency, :usd) }
      let(:asset) { create(:asset) }

      let!(:newest_asset_price) do
        create(:asset_price, :updated, :with_hg_brasil_stock_price_partner_resource, asset:, currency:, reference_date:
        Time.zone.now)
      end

      before do
        create(:asset_price, :updated, :with_hg_brasil_stock_price_partner_resource, asset:, currency: another_currency,
                                                                                     reference_date: 2.hours.ago)
        second_currency_parity = create(:currency_parity, currency_from: another_currency, currency_to: currency)
        create(:currency_parity_exchange_rate, :with_hg_brasil_stock_price_partner_resource, :updated,
               currency_parity: second_currency_parity)
      end

      it { is_expected.to eq(newest_asset_price) }
    end

    context 'when there is no updated asset price' do
      context 'when arguments are incorrect' do
        context 'when asset is not present' do
          let(:asset) { nil }
          let(:currency) { create(:currency) }

          it { expect { newest_updated_asset_price_service }.to raise_error(ArgumentError, 'Asset must be present') }
        end

        context 'when currency is not present' do
          let(:asset) { create(:asset) }
          let(:currency) { nil }

          it { expect { newest_updated_asset_price_service }.to raise_error(ArgumentError, 'Currency must be present') }
        end
      end

      context 'when asset price currency is the same as the currency' do
        let(:currency) { create(:currency, :brl) }
        let(:asset) { create(:asset) }

        before do
          create(:asset_price, :scheduled, :with_hg_brasil_stock_price_partner_resource, asset:, currency:)
        end

        it {
          expect do
            newest_updated_asset_price_service
          end.to raise_error(Assets::OutdatedError, "Asset with id: #{asset.id} is outdated.")
        }
      end

      context 'when currency parity does not exist' do
        let(:currency) { create(:currency, :brl) }
        let(:another_currency) { create(:currency, :usd) }
        let(:asset) { create(:asset) }

        before do
          create(:asset_price, :updated, :with_hg_brasil_stock_price_partner_resource, asset:, currency: another_currency)
        end

        it {
          expect do
            newest_updated_asset_price_service
          end.to raise_error(Assets::OutdatedError, "Asset with id: #{asset.id} is outdated.")
        }
      end

      context 'when currency parity exists but there is no updated currency parity exchange rate' do
        let(:currency) { create(:currency, :brl) }
        let(:another_currency) { create(:currency, :usd) }
        let(:asset) { create(:asset) }

        before do
          create(:asset_price, :updated, :with_hg_brasil_stock_price_partner_resource, asset:, currency: another_currency)
          second_currency_parity = create(:currency_parity, currency_from: currency, currency_to: another_currency)
          create(:currency_parity_exchange_rate, :with_hg_brasil_stock_price_partner_resource, :scheduled,
                 currency_parity: second_currency_parity)
        end

        it {
          expect do
            newest_updated_asset_price_service
          end.to raise_error(Assets::OutdatedError, "Asset with id: #{asset.id} is outdated.")
        }
      end
    end
  end
end
