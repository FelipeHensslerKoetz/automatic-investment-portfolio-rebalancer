class InvestmentPortfolioAsset < ApplicationRecord
  belongs_to :asset
  belongs_to :investment_portfolio
end
