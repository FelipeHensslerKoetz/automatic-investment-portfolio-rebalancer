# frozen_string_literal: true

class InvestmentPortfolioRebalanceNotificationOrder < ApplicationRecord
  # Modules
  include AASM

  # Associations
  belongs_to :investment_portfolio
  belongs_to :investment_portfolio_rebalance_notification_option
  belongs_to :rebalance
  belongs_to :rebalance_order

  # State Machine
  aasm column: :status do
    state :pending, initial: true
    state :processing
    state :success
    state :error

    event :process do
      transitions from: :pending, to: :processing
    end

    event :success do
      transitions from: :processing, to: :success
    end

    event :error do
      transitions from: :processing, to: :error
    end

    event :reprocess do
      transitions from: :error, to: :processing, after: :clean_error_message_and_increment_retry_count
    end
  end

  private 

  def clean_error_message_and_increment_retry_count
    update!(error_message: nil, retry_count: retry_count + 1)
  end
end
