# frozen_string_literal: true

class AssetPrice < ApplicationRecord
  # Modules
  include AASM

  # Associations
  belongs_to :asset
  belongs_to :currency
  belongs_to :partner_resource

  # Validations
  validates :ticker_symbol, :price, :last_sync_at, :reference_date, :status, presence: true

  # Scopes
  scope :updated, -> { where(status: :updated) }
  scope :scheduled, -> { where(status: :scheduled) }
  scope :processing, -> { where(status: :processing) }
  scope :failed, -> { where(status: :failed) }

  # AASM
  aasm column: :status do
    state :scheduled
    state :processing
    state :updated, initial: true
    state :failed

    event :schedule do
      transitions from: %i[failed updated], to: :scheduled
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
  end
end
