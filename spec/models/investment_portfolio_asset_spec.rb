# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvestmentPortfolioAsset, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:asset) }
    it { is_expected.to belong_to(:investment_portfolio) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:target_allocation_weight_percentage) }
    it { is_expected.to validate_presence_of(:quantity) }

    it 'validates target_allocation_weight_percentage is greater than or equal to 0 and less than or equal to 100' do
      investment_portfolio_asset = build(:investment_portfolio_asset, target_allocation_weight_percentage: 101)
      investment_portfolio_asset.valid?

      expect(investment_portfolio_asset.errors[:target_allocation_weight_percentage]).to include(
        'must be less than or equal to 100')
      expect(investment_portfolio_asset).to be_invalid
    end

    it 'validates target_variation_limit_percentage is greater than or equal to 0' do
      investment_portfolio_asset = build(:investment_portfolio_asset, target_variation_limit_percentage: -10)
      investment_portfolio_asset.valid?

      expect(investment_portfolio_asset.errors[:target_variation_limit_percentage]).to include('must be greater than or equal to 0')
      expect(investment_portfolio_asset).to be_invalid
    end

    it 'validates that :quantity is greater than or equal to 0' do
      investment_portfolio_asset = build(:investment_portfolio_asset, quantity: -1)
      investment_portfolio_asset.valid?

      expect(investment_portfolio_asset.errors[:quantity]).to include('must be greater than or equal to 0')
      expect(investment_portfolio_asset).to be_invalid
    end

    it 'validates that :target_variation_limit_percentage is grater than or equal to 0 (when not null)' do
      investment_portfolio_asset = build(:investment_portfolio_asset, target_variation_limit_percentage: -1)
      investment_portfolio_asset.valid?

      expect(investment_portfolio_asset.errors[:target_variation_limit_percentage]).to include('must be greater than or equal to 0')
      expect(investment_portfolio_asset).to be_invalid
    end

    context 'investment_portfolio_id and asset_id unique index' do 
      let!(:investment_portfolio_asset) { create(:investment_portfolio_asset) }

      it 'validates investment_portfolio_id uniqueness with scope asset_id' do
        new_investment_portfolio_asset = build(:investment_portfolio_asset, investment_portfolio: investment_portfolio_asset.investment_portfolio, asset: investment_portfolio_asset.asset)
        new_investment_portfolio_asset.valid?

        expect(new_investment_portfolio_asset.errors[:investment_portfolio_id]).to include('has already been taken')
        expect(new_investment_portfolio_asset).to be_invalid
      end
    end
  end
end
