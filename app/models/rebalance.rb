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
  scope :succeed, -> { where(status: :succeed) }
  scope :failed, -> { where(status: :failed) }

  # AASM
  aasm column: :status do
    state :pending, initial: true
    state :processing
    state :succeed
    state :failed

    event :process do
      transitions from: %i[pending failed], to: :processing
    end

    event :success do
      transitions from: :processing, to: :succeed
    end

    event :fail do
      transitions from: :processing, to: :failed
    end
  end
end
