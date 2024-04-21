# frozen_string_literal: true

class Rebalance < ApplicationRecord
  # Modules
  include AASM

  # Associations
  belongs_to :rebalance_order

  # Validations
  validates :before_state, :after_state, :details, :recommended_actions, :status, presence: true

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
      transitions from: %i[pending failed], to: :processing
    end

    event :finish do
      transitions from: :processing, to: :finished
    end

    event :fail do
      transitions from: :processing, to: :failed
    end
  end
end
