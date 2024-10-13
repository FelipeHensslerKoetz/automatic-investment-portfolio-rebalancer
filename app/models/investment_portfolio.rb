# frozen_string_literal: true

class InvestmentPortfolio < ApplicationRecord
  # Relationships
  belongs_to :user
  has_one :automatic_rebalance_option, dependent: :restrict_with_error
  has_many :investment_portfolio_assets, dependent: :restrict_with_error
  has_many :assets, through: :investment_portfolio_assets
  has_many :investment_portfolio_rebalance_notification_options, dependent: :restrict_with_error
  has_many :investment_portfolio_rebalance_notification_orders, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
end
