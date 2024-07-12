# frozen_string_literal: true

class AutomaticRebalanceOption < ApplicationRecord
  AUTOMATIC_REBALANCE_OPTIONS = %w[deviation recurrence].freeze

  # Associations
  belongs_to :investment_portfolio

  # Validations
  validates :kind, inclusion: { in: AUTOMATIC_REBALANCE_OPTIONS }
  validates :kind, :start_date, presence: true
  validates :recurrence_days, numericality: { only_integer: true, greater_than: 0 }, if: -> { kind == 'recurrence' }
  validates :investment_portfolio_id, uniqueness: true

  # Scopes
  scope :deviation, -> { where(kind: 'deviation') }
  scope :recurrence, -> { where(kind: 'recurrence') }
end
