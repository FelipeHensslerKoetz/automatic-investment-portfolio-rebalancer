# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssetPrice, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:asset) }
    it { is_expected.to belong_to(:partner_resource).optional }
    it { is_expected.to belong_to(:currency) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_presence_of(:last_sync_at) }
    it { is_expected.to validate_presence_of(:reference_date) }

    context 'when asset is not custom' do
      let!(:asset) { create(:asset, custom: false) }
      let(:asset_price) { build(:asset_price, asset:) }

      before do
        asset_price.partner_resource = nil
      end

      it 'validates presence of partner_resource' do
        expect(asset_price).to be_invalid
      end
    end

    context 'when asset is custom' do
      let!(:asset) { create(:asset, custom: true) }
      let(:asset_price) { build(:asset_price, asset:) }

      before do
        asset_price.partner_resource = nil
      end

      it 'does not validate presence of partner_resource' do
        expect(asset_price).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:pending_asset_price) { create(:asset_price, :with_hg_brasil_assets_partner_resource, :pending) }
    let!(:scheduled_asset_price) { create(:asset_price, :with_hg_brasil_assets_partner_resource, :scheduled) }
    let!(:updated_asset_price) { create(:asset_price, :with_hg_brasil_assets_partner_resource, :updated) }
    let!(:processing_asset_price) { create(:asset_price, :with_hg_brasil_assets_partner_resource, :processing) }
    let!(:failed_asset_price) { create(:asset_price, :with_hg_brasil_assets_partner_resource, :failed) }

    describe '.scheduled' do
      it 'returns scheduled asset prices' do
        expect(AssetPrice.scheduled).to contain_exactly(scheduled_asset_price)
      end
    end

    describe '.updated' do
      it 'returns up to date asset prices' do
        expect(AssetPrice.updated).to contain_exactly(updated_asset_price)
      end
    end

    describe '.processing' do
      it 'returns processing asset prices' do
        expect(AssetPrice.processing).to contain_exactly(processing_asset_price)
      end
    end

    describe '.failed' do
      it 'returns failed asset prices' do
        expect(AssetPrice.failed).to contain_exactly(failed_asset_price)
      end
    end

    describe '.pending' do
      it 'returns pending asset prices' do
        expect(AssetPrice.pending).to contain_exactly(pending_asset_price)
      end
    end
  end

  describe 'aasm' do
    it { should transition_from(:pending).to(:scheduled).on_event(:schedule) }
    it { should transition_from(:scheduled).to(:processing).on_event(:process) }
    it { should transition_from(:processing).to(:failed).on_event(:fail) }
    it { should transition_from(:processing).to(:updated).on_event(:up_to_date) }
    it { should transition_from(:failed).to(:pending).on_event(:reset_asset_price) }
    it { should transition_from(:updated).to(:pending).on_event(:reset_asset_price) }
  end
end
