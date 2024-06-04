# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvestmentPortfolios::InvalidTotalAllocationWeightError do
  let(:investment_portfolio) { create(:investment_portfolio) }
  let(:current_allocation_weight) { 101.0 }

  subject { described_class.new(investment_portfolio:, current_allocation_weight:) }

  describe '#message' do
    it 'returns the correct error message' do
      expect(subject.message).to eq("Investment Portfolio id: #{investment_portfolio.id} has an invalid total allocation " \
                                    "weight: #{current_allocation_weight}")
    end
  end
end
