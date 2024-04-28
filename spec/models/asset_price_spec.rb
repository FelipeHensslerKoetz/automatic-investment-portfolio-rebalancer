# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssetPrice, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:asset) }
    it { is_expected.to belong_to(:partner_resource) }
    it { is_expected.to belong_to(:currency) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_presence_of(:last_sync_at) }
    it { is_expected.to validate_presence_of(:reference_date) }
  end

  describe 'scopes' do
    let!(:scheduled_asset_price) { create(:asset_price, :with_hg_brasil_stock_price_partner_resource, :scheduled) }
    let!(:updated_asset_price) { create(:asset_price, :with_hg_brasil_stock_price_partner_resource, :updated) }
    let!(:processing_asset_price) { create(:asset_price, :with_hg_brasil_stock_price_partner_resource, :processing) }
    let!(:failed_asset_price) { create(:asset_price, :with_hg_brasil_stock_price_partner_resource, :failed) }

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
  end

  describe 'aasm' do
    it { should have_state(:updated) }
    it { should transition_from(:updated).to(:scheduled).on_event(:schedule) }
    it { should transition_from(:failed).to(:scheduled).on_event(:schedule) }
    it { should transition_from(:scheduled).to(:processing).on_event(:process) }
    it { should transition_from(:processing).to(:failed).on_event(:fail) }
    it { should transition_from(:processing).to(:updated).on_event(:up_to_date) }
  end
end
