# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvestmentPortfolioAsset, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:asset) }
    it { is_expected.to belong_to(:investment_portfolio) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:allocation_weight) }
    it { is_expected.to validate_presence_of(:deviation_percentage) }
    it { is_expected.to validate_presence_of(:quantity) }

    it 'validates that :allocation_weight is greater than or equal to 0 and less than or equal to 100' do
      investment_portfolio_asset = build(:investment_portfolio_asset, allocation_weight: 101)
      investment_portfolio_asset.valid?

      expect(investment_portfolio_asset.errors[:allocation_weight]).to include('must be less than or equal to 100')
      expect(investment_portfolio_asset).to be_invalid
    end

    it 'validates that :deviation_percentage is greater than or equal to 0 and less than or equal to 100' do
      investment_portfolio_asset = build(:investment_portfolio_asset, deviation_percentage: 101)
      investment_portfolio_asset.valid?

      expect(investment_portfolio_asset.errors[:deviation_percentage]).to include('must be less than or equal to 100')
      expect(investment_portfolio_asset).to be_invalid
    end

    it 'validates that :quantity is greater than or equal to 0' do
      investment_portfolio_asset = build(:investment_portfolio_asset, quantity: -1)
      investment_portfolio_asset.valid?

      expect(investment_portfolio_asset.errors[:quantity]).to include('must be greater than or equal to 0')
      expect(investment_portfolio_asset).to be_invalid
    end
  end
end
