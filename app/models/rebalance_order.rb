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
  scope :processing, -> { where(status: :processing) }
  scope :finished, -> { where(status: :finished) }
  scope :failed, -> { where(status: :failed) }

  # AASM
  aasm column: :status do
    state :pending, initial: true
    state :processing
    state :finished
    state :failed

    event :process do
      transitions from: :pending, to: :processing
    end

    event :finish do
      transitions from: :processing, to: :finished
    end

    event :fail do
      transitions from: :processing, to: :failed
    end

    event :reprocess do
      transitions from: %i[failed], to: :pending
    end
  end
end
