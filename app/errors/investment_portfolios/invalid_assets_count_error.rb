# frozen_string_literal: true

module InvestmentPortfolios
  class InvalidAssetsCountError < StandardError
    def initialize(investment_portfolio:)
      super("Investment Portfolio #{investment_portfolio.id} has an invalid number of assets: #{investment_portfolio.assets.count}")
    end
  end
end
