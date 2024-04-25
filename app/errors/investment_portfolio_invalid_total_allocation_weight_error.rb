# frozen_string_literal: true

class InvestmentPortfolioInvalidTotalAllocationWeightError < StandardError
  def initialize(investment_portfolio:)
    super("Investment Portfolio id: #{investment_portfolio.id} has an invalid total allocation weight: #{investment_portfolio.total_allocation_weight}")
  end
end
