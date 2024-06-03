# frozen_string_literal: true

module InvestmentPortfolios
  class InvalidTotalAllocationWeightError < StandardError
    def initialize(investment_portfolio:, current_allocation_weight:)
      super("Investment Portfolio id: #{investment_portfolio.id} has an invalid total allocation weight: #{current_allocation_weight}")
    end
  end
end
