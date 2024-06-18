# frozen_string_literal: true

class RebalanceOrder < ApplicationRecord
  # Modules
  include AASM

  # Constants
  REBALANCE_ORDER_KINDS = %w[default deposit withdraw].freeze

  # Associations
  belongs_to :user
  belongs_to :investment_portfolio
  has_one :rebalance, dependent: :restrict_with_error

  # Validations
  validates :status, :kind, :amount, presence: true
  validates :kind, inclusion: { in: REBALANCE_ORDER_KINDS }
  validates :amount, numericality: { greater_than: 0 }, if: -> { kind == 'deposit' || kind == 'withdraw' }
  before_validation :set_default_amount, if: -> { kind == 'default' }

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

  private

  def set_default_amount
    self.amount = 0
  end
end
