# frozen_string_literal: true

class AutomaticRebalanceOption < ApplicationRecord
  # Constants
  AUTOMATIC_REBALANCE_OPTIONS = %w[variation recurrence].freeze
  REBALANCE_ORDER_KINDS = RebalanceOrder::REBALANCE_ORDER_KINDS

  # Associations
  belongs_to :investment_portfolio

  # Validations
  validates :kind, inclusion: { in: AUTOMATIC_REBALANCE_OPTIONS }
  validates :kind, :start_date, :rebalance_order_kind, presence: true
  validates :recurrence_days, numericality: { only_integer: true, greater_than: 0 }, if: -> { kind == 'recurrence' }
  validates :investment_portfolio_id, uniqueness: true
  validates :rebalance_order_kind, inclusion: { in: REBALANCE_ORDER_KINDS }
  before_validation :set_default_amount, if: -> { amount.nil? && rebalance_order_kind_default? }
  validates :amount, numericality: { greater_than: 0 }, if: -> { rebalance_order_kind_contribution? }

  # Scopes
  scope :variation, -> { where(kind: 'variation') }
  scope :recurrence, -> { where(kind: 'recurrence') }

  def variation?
    kind == 'variation'
  end

  def recurrence?
    kind == 'recurrence'
  end

  def rebalance_order_kind_default?
    rebalance_order_kind == 'default'
  end

  def rebalance_order_kind_contribution?
    rebalance_order_kind == 'contribution'
  end

  private 

  def set_default_amount
    self.amount = 0
  end
end
