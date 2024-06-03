# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvestmentPortfolios::InvalidAssetsCountError do
  describe '#initialize' do
    let(:investment_portfolio) { build(:investment_portfolio) }
    let(:error) { described_class.new(investment_portfolio:) }

    it 'returns the error message' do
      expect(error.message).to eq("Investment Portfolio #{investment_portfolio.id} has an invalid number of assets: #{investment_portfolio.assets.count}")
    end
  end
end
