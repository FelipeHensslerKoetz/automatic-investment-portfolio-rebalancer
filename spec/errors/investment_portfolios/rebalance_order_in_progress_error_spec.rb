# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvestmentPortfolios::RebalanceOrderInProgressError, type: :error do
  describe '#initialize' do
    it 'returns a message with the investment_portfolio id' do
      investment_portfolio = create(:investment_portfolio)
      error = described_class.new(investment_portfolio:)

      expect(error.message).to eq("Investment Portfolio with id= #{investment_portfolio.id} has a rebalance order in progress")
    end
  end
end
