# frozen_string_literal: true

class CurrencyParityExchangeRate < ApplicationRecord
  # Modules
  include AASM

  # Associations
  belongs_to :currency_parity
  belongs_to :partner_resource

  # Validations
  validates :exchange_rate, :reference_date, :last_sync_at, presence: true

  # Scopes
  scope :updated, -> { where(status: :updated) }
  scope :scheduled, -> { where(status: :scheduled) }
  scope :processing, -> { where(status: :processing) }
  scope :outdated, -> { where(status: :outdated) }
  scope :failed, -> { where(status: :failed) }

  # AASM
  aasm column: :status do
    state :updated, initial: true
    state :scheduled
    state :processing
    state :outdated
    state :failed

    event :schedule do
      transitions from: %i[outdated failed], to: :scheduled
    end

    event :process do
      transitions from: :scheduled, to: :processing
    end

    event :fail do
      transitions from: :processing, to: :failed
    end

    event :up_to_date do
      transitions from: :processing, to: :updated
    end

    event :out_of_date do
      transitions from: :updated, to: :outdated
    end
  end
end
