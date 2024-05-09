# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Asset, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to have_many(:asset_prices).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:ticker_symbol) }
    it { is_expected.to validate_inclusion_of(:kind).in_array(Asset::ASSET_KINDS.map(&:to_s)) }

    it 'validates uniqueness of ticker_symbol' do
      create(:asset, ticker_symbol: 'AAPL')
      asset = build(:asset, ticker_symbol: 'AAPL')

      expect(asset).to be_invalid
      expect(asset.errors[:ticker_symbol]).to include('has already been taken')
    end
  end

  describe 'scopes' do
    describe '.global' do
      it 'returns all global assets' do
        global_asset = create(:asset, custom: false)
        create(:asset, custom: true)

        expect(Asset.global).to eq([global_asset])
      end
    end

    describe '.custom_by_user' do
      it 'returns all custom assets by user' do
        user = create(:user)
        custom_asset = create(:asset, custom: true, user:)
        create(:asset, custom: true)

        expect(Asset.custom_by_user(user)).to eq([custom_asset])
      end
    end
  end

  describe 'class methods' do
    describe '.find' do
      it 'finds an asset by id' do
        asset = create(:asset)
        found_asset = Asset.find(asset.id)

        expect(found_asset).to eq(asset)
      end

      it 'finds an asset by ticker_symbol' do
        asset = create(:asset)
        found_asset = Asset.find(asset.ticker_symbol)

        expect(found_asset).to eq(asset)
      end

      it 'raises an error if asset is not found' do
        expect { Asset.find('AAPL') }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
