# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvestmentPortfolio, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:currency) }
    it { should have_many(:investment_portfolio_assets).dependent(:restrict_with_error) }
    it { should have_many(:assets).through(:investment_portfolio_assets) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
