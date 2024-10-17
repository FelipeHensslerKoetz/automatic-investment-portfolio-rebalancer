# frozen_string_literal: true

class Rebalance < ApplicationRecord
  # Modules
  include AASM

  # Associations
  belongs_to :rebalance_order
  has_many :investment_portfolio_rebalance_notification_orders, dependent: :destroy
end
