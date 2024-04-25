# frozen_string_literal: true

class InvestmentPortfolio < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :currency
  has_many :investment_portfolio_assets, dependent: :restrict_with_error
  has_many :assets, through: :investment_portfolio_assets

  # Validations
  validates :name, presence: true

  # Nested Attributes
  accepts_nested_attributes_for :investment_portfolio_assets, allow_destroy: true
end
