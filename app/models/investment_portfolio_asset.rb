# frozen_string_literal: true

class InvestmentPortfolioAsset < ApplicationRecord
  # Associations
  belongs_to :asset
  belongs_to :investment_portfolio

  # Validations
  validates :target_allocation_weight,
            :target_deviation_percentage,
            presence: true,
            numericality: { greater_than_or_equal: 0, less_than_or_equal_to: 100 }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
