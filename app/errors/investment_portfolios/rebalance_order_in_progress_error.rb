# frozen_string_literal: true

module InvestmentPortfolios
  class RebalanceOrderInProgressError < StandardError
    attr_reader :investment_portfolio

    def initialize(investment_portfolio:)
      super("Investment Portfolio with id= #{investment_portfolio.id} has a rebalance order in progress")
    end
  end
end
