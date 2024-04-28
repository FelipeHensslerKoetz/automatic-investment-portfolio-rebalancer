# frozen_string_literal: true

class RebalanceOrder < ApplicationRecord
  # Modules
  include AASM

  # Constants
  REBALANCE_ORDER_KINDS = %w[default deposit withdraw].freeze

  # Associations
  belongs_to :user
  belongs_to :investment_portfolio

  # Validations
  validates :status, :kind, :amount, :scheduled_at, presence: true
  validates :kind, inclusion: { in: REBALANCE_ORDER_KINDS }

  # Scopes
  scope :pending, -> { where(status: :pending) }
  scope :scheduled, -> { where(status: :scheduled) }
  scope :processing, -> { where(status: :processing) }
  scope :succeed, -> { where(status: :succeed) }
  scope :failed, -> { where(status: :failed) }

  # AASM
  aasm column: :status do
    state :pending, initial: true
    state :scheduled
    state :processing
    state :succeed
    state :failed

    event :schedule do
      transitions from: :pending, to: :scheduled
    end

    event :process do
      transitions from: :scheduled, to: :processing
    end

    event :success do
      transitions from: :processing, to: :succeed
    end

    event :fail do
      transitions from: :processing, to: :failed
    end

    event :retry do
      transitions from: :failed, to: :pending
    end
  end
end
