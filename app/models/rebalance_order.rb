class RebalanceOrder < ApplicationRecord
  # Modules
  include AASM

  # Constants
  REBALANCE_ORDER_TYPES = %w[default deposit withdraw].freeze

  # Associations
  belongs_to :user
  belongs_to :investment_portfolio

  # Validations
  validates :status, :type, :amount, :scheduled_at, presence: true
  validates :type, inclusion: { in: REBALANCE_ORDER_TYPES }

  # Scopes
  scope :scheduled, -> { where(status: :scheduled) }
  scope :processing, -> { where(status: :processing) }
  scope :finished, -> { where(status: :finished) }
  scope :failed, -> { where(status: :failed) }

  # AASM
  aasm column: :status do
    state :scheduled, initial: true
    state :processing
    state :finished
    state :failed

    event :process do
      transitions from: :scheduled, to: :processing
    end

    event :finish do
      transitions from: :processing, to: :finished
    end

    event :fail do
      transitions from: :processing, to: :failed
    end

    event :schedule do
      transitions from: %i[failed], to: :scheduled
    end
  end
end
