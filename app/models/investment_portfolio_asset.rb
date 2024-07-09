# frozen_string_literal: true

class InvestmentPortfolioAsset < ApplicationRecord
  # Associations
  belongs_to :asset
  belongs_to :investment_portfolio

  # Validations
  validates :target_allocation_weight_percentage, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :target_variation_limit_percentage, presence: true, numericality: { greater_than_or_equal_to: 0 } # TODO: rever se for nil -> obrigar apenas quando método selecionado for por dessvio
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :investment_portfolio_id, uniqueness: { scope: :asset_id }
end
