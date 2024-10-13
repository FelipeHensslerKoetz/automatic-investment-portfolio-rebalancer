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
  has_many :investment_portfolio_rebalance_notification_orders, dependent: :restrict_with_error

  # Validations
  validates :status, :kind, :amount, :scheduled_at, presence: true
  validates :kind, inclusion: { in: REBALANCE_ORDER_KINDS }
  validates :amount, numericality: { greater_than: 0 }, if: -> { kind == 'deposit' || kind == 'withdraw' }
  before_validation :set_default_amount, if: -> { kind == 'default' }
  before_validation :set_default_scheduled_at, if: -> { scheduled_at.nil? }
  validate :scheduled_at_cannot_be_in_the_past

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

  def scheduled_at_cannot_be_in_the_past
    return if scheduled_at >= Time.zone.today 

    errors.add(:scheduled_at, 'can not be in the past')
  end

  def set_default_scheduled_at
    self.scheduled_at = Time.zone.today
  end
end
