# frozen_string_literal: true

class InvestmentPortfolioSerializer < ActiveModel::Serializer
  attributes :id, :name, :description

  has_many :investment_portfolio_assets
  belongs_to :currency
end
