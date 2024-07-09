# frozen_string_literal: true

require 'rails_helper'

RSpec.describe System::AssetPrices::UpdatedAssetPriceService do
  subject(:updated_asset_price_service) { described_class.call(asset:) }

  let!(:brl_currency) { create(:currency, :brl) }

  describe '.call' do
    context 'when there is a updated asset price' do
      let(:usd_currency) { create(:currency, :usd) }
      let(:asset) { create(:asset) }

      context 'when there is only hg brasil stock price partner resource' do
        let!(:hg_brasil_asset_price) do
          create(:asset_price, :updated, :with_hg_brasil_assets_partner_resource, asset:, currency: brl_currency, reference_date:
          Time.zone.now)
        end

        it { is_expected.to eq(hg_brasil_asset_price) }
      end

      context 'when there is only br_api partner resource' do
        let!(:br_api_asset_price) do
          create(:asset_price, :updated, :with_br_api_assets_partner_resource, asset:, currency: brl_currency, reference_date:
          Time.zone.now)
        end

        it { is_expected.to eq(br_api_asset_price) }
      end

      context 'when there are multiple partner resources' do
        let!(:hg_brasil_newest_asset_price) do
          create(:asset_price, :updated, :with_hg_brasil_assets_partner_resource, asset:, currency: brl_currency, reference_date:
          Time.zone.today.beginning_of_day + 1.hour)
        end

        let!(:br_api_newest_asset_price) do
          create(:asset_price, :updated, :with_br_api_assets_partner_resource, asset:, currency: brl_currency, reference_date:
          Time.zone.today.beginning_of_day)
        end

        it 'returns the updated asset price based on partner_resource priority' do
          expect(updated_asset_price_service).to eq(br_api_newest_asset_price)
        end
      end
    end

    context 'when there is no updated asset price' do
      context 'when arguments are incorrect' do
        context 'when asset is not present' do
          let(:asset) { nil }

          it { expect { updated_asset_price_service }.to raise_error(ArgumentError, 'Asset must be present') }
        end
      end

      context 'when asset price currency is the same as the currency' do
        let(:asset) { create(:asset) }

        before do
          create(:asset_price, :scheduled, :with_hg_brasil_assets_partner_resource, asset:, currency: brl_currency)
        end

        it {
          expect do
            updated_asset_price_service
          end.to raise_error(Assets::OutdatedError, "Asset with id: #{asset.id} is outdated.")
        }
      end

      context 'when currency parity does not exist' do
        let(:usd_currency) { create(:currency, :usd) }
        let(:asset) { create(:asset) }

        before do
          create(:asset_price, :updated, :with_hg_brasil_assets_partner_resource, asset:, currency: usd_currency)
        end

        it {
          expect do
            updated_asset_price_service
          end.to raise_error(Assets::OutdatedError, "Asset with id: #{asset.id} is outdated.")
        }
      end

      context 'when currency parity exists but there is no updated currency parity exchange rate' do
        let(:usd_currency) { create(:currency, :usd) }
        let(:asset) { create(:asset) }

        before do
          create(:asset_price, :updated, :with_hg_brasil_assets_partner_resource, asset:, currency: usd_currency)
          second_currency_parity = create(:currency_parity, currency_from: brl_currency, currency_to: usd_currency)
          create(:currency_parity_exchange_rate, :with_hg_brasil_currencies_partner_resource, :scheduled,
                 currency_parity: second_currency_parity)
        end

        it {
          expect do
            updated_asset_price_service
          end.to raise_error(Assets::OutdatedError, "Asset with id: #{asset.id} is outdated.")
        }
      end
    end
  end
end
