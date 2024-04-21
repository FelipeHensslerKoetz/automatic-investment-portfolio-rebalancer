# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvestmentPortfolio, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:currency) }
    it { should have_many(:investment_portfolio_assets).dependent(:restrict_with_error) }
    it { should accept_nested_attributes_for(:investment_portfolio_assets).allow_destroy(true) }
    it { should have_many(:assets).through(:investment_portfolio_assets) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'methods' do
    describe '#total_allocation_weight' do
      context 'when there are no investment_portfolio_assets' do
        it 'returns 0' do
          investment_portfolio = create(:investment_portfolio)

          expect(investment_portfolio.total_allocation_weight).to eq(0.to_d)
          expect(investment_portfolio.total_allocation_weight).to be_a(BigDecimal)
        end
      end

      context 'when there are investment_portfolio_assets' do
        it 'returns the sum of the allocation weights of the investment_portfolio_assets' do
          investment_portfolio = create(:investment_portfolio)
          create(:investment_portfolio_asset, investment_portfolio:, allocation_weight: 50)
          create(:investment_portfolio_asset, investment_portfolio:, allocation_weight: 50)

          expect(investment_portfolio.total_allocation_weight).to eq(100.to_d)
          expect(investment_portfolio.total_allocation_weight).to be_a(BigDecimal)
        end
      end
    end

    describe '#valid_total_allocation_weight?' do
      it 'returns true if the total allocation weight is equal to 100' do
        investment_portfolio = create(:investment_portfolio)
        create(:investment_portfolio_asset, investment_portfolio:, allocation_weight: 50.0)
        create(:investment_portfolio_asset, investment_portfolio:, allocation_weight: 50.0)

        expect(investment_portfolio.valid_total_allocation_weight?).to be_truthy
      end

      it 'returns false if the total allocation weight is less than 100' do
        investment_portfolio = create(:investment_portfolio)
        create(:investment_portfolio_asset, investment_portfolio:, allocation_weight: 50)
        create(:investment_portfolio_asset, investment_portfolio:, allocation_weight: 49)

        expect(investment_portfolio.valid_total_allocation_weight?).to be_falsey
      end
    end
  end
end
