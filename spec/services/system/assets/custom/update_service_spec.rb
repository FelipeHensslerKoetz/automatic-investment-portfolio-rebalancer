require 'rails_helper'

RSpec.describe System::Assets::Custom::UpdateService do
  subject(:update_service) { described_class.call(custom_asset:, custom_asset_params:) }

  let!(:user) { create(:user) }

  describe '.call' do
    context 'when the update can be performed' do
      let!(:custom_asset) { create(:asset, :custom, user:) }
      let!(:custom_asset_price) { create(:asset_price, asset: custom_asset, partner_resource: nil) }
      let!(:btc_currency) { create(:currency, :btc) }

      let(:custom_asset_params) do
        {
          name: 'My Custom Asset Updated',
          price: 25.0,
          currency_code: 'BTC'
        }
      end

      it 'updates the custom asset and asset price' do
        update_service

        expect(custom_asset.reload.attributes).to include(
          'name' => custom_asset_params[:name],
          'ticker_symbol' => "#{user.email} - #{custom_asset_params[:name]}",
          'user_id' => user.id,
          'custom' => true
        )

        expect(custom_asset_price.reload.attributes).to include(
          'price' => custom_asset_params[:price],
          'currency_id' => btc_currency.id,
          'partner_resource_id' => nil,
          'asset_id' => custom_asset.id,
          'status' => 'updated'
        )

        expect(Asset.count).to eq(1)
        expect(AssetPrice.count).to eq(1)
      end
    end

    context 'when the update cannot be performed' do
      context 'when there is a RebalanceOrder being processed' do
        let!(:custom_asset) { create(:asset, :custom, user:) }
        let!(:custom_asset_price) { create(:asset_price, asset: custom_asset, partner_resource: nil) }
        let!(:btc_currency) { create(:currency, :btc) }

        let(:custom_asset_params) do
          {
            name: 'My Custom Asset Updated',
            price: 25.0,
            currency_code: 'BTC'
          }
        end

        before do
          create(:rebalance_order, :processing, user:)
        end

        it 'raises an error' do
          expect { update_service }.to raise_error(StandardError, 'Asset cannot be updated while there is a RebalanceOrder being processed or scheduled')
        end
      end

      context 'when there is a RebalanceOrder being scheduled' do
        let!(:custom_asset) { create(:asset, :custom, user:) }
        let!(:custom_asset_price) { create(:asset_price, asset: custom_asset, partner_resource: nil) }
        let!(:btc_currency) { create(:currency, :btc) }

        let(:custom_asset_params) do
          {
            name: 'My Custom Asset Updated',
            price: 25.0,
            currency_code: 'BTC'
          }
        end

        before do
          create(:rebalance_order, :scheduled, user:)
        end

        it 'raises an error' do
          expect { update_service }.to raise_error(StandardError, 'Asset cannot be updated while there is a RebalanceOrder being processed or scheduled')
        end
      end

      context 'when the asset is not custom' do
        let(:custom_asset) { create(:asset, custom: false, user: nil) }
        let!(:custom_asset_price) { create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: custom_asset) }
        let!(:btc_currency) { create(:currency, :btc) }

        let(:custom_asset_params) do
          {
            name: 'My Custom Asset Updated',
            price: 25.0,
            currency_code: 'BTC'
          }
        end

        it 'raises an error' do
          expect { update_service }.to raise_error(StandardError, 'Asset must be custom')
        end
      end
    end
  end
end
