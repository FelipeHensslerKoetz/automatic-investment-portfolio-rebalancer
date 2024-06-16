# frozen_string_literal: true

class InvestmentPortfolioAsset < ApplicationRecord
  # Associations
  belongs_to :asset
  belongs_to :investment_portfolio

  # Validations
  validate :valid_target_allocation_weight_percentage
  validate :valid_target_variation_limit_percentage
  validate :valid_quantity

  validates :target_allocation_weight_percentage, :quantity, presence: true

  private

  def valid_target_allocation_weight_percentage
    raise StandardError unless target_allocation_weight_percentage.positive? && target_allocation_weight_percentage <= 100
  rescue StandardError
    errors.add(:target_allocation_weight_percentage, 'must be greater than 0 and less than or equal to 100')
  end

  def valid_target_variation_limit_percentage
    return if target_variation_limit_percentage.nil?

    raise StandardError unless target_variation_limit_percentage.positive? && target_variation_limit_percentage <= 100
  rescue StandardError
    errors.add(:target_variation_limit_percentage, 'must be greater than 0 and less than or equal to 100')
  end

  def valid_quantity
    raise StandardError unless quantity.positive?
  rescue StandardError
    errors.add(:quantity, 'must be greater than 0')
  end
end
