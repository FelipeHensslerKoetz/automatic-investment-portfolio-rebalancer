# frozen_string_literal: true

require 'rails_helper'

RSpec.describe System::Assets::Custom::CreatorService do
  subject(:creator_service) { described_class.call(user:, custom_asset_params:) }

  let(:user) { create(:user) }
  let!(:brl_currency) { create(:currency, :brl) }

  describe '.call' do
    context 'when the custom asset can be created' do
      let(:custom_asset_params) do
        {
          name: 'My Custom Asset',
          price: 100,
          currency_code: 'BRL'
        }
      end

      it 'creates a new custom asset and asset price' do
        creator_service

        new_custom_asset = user.assets.first
        new_asset_price = new_custom_asset.asset_prices.first

        expect(Asset.count).to eq(1)
        expect(AssetPrice.count).to eq(1)
        expect(user.assets.count).to eq(1)
        expect(new_custom_asset.asset_prices.count).to eq(1)
        expect(new_custom_asset.attributes).to include(
          'ticker_symbol' => "#{user.email} - #{custom_asset_params[:name]}",
          'name' => custom_asset_params[:name],
          'custom' => true,
          'kind' => 'custom'
        )
        expect(new_asset_price.attributes).to include(
          'ticker_symbol' => "#{user.email} - #{custom_asset_params[:name]}",
          'price' => custom_asset_params[:price],
          'currency_id' => brl_currency.id,
          'partner_resource_id' => nil,
          'status' => 'updated'
        )
      end
    end

    context 'when the custom asset cannot be created' do
      context 'when custom asset params are invalid' do
        let(:custom_asset_params) { {} }

        it 'raises an error' do
          expect { creator_service }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when the asset already exists' do
        let(:custom_asset_params) do
          {
            name: 'My Custom Asset',
            price: 100,
            currency_code: 'BRL'
          }
        end

        before do
          create(:asset, user:, custom: true, kind: 'custom', name: 'My Custom Asset',
                         ticker_symbol: "#{user.email} - My Custom Asset")
        end

        it 'raises an error' do
          expect { creator_service }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
