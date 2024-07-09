# frozen_string_literal: true

class AssetPrice < ApplicationRecord
  # Modules
  include AASM

  # Associations
  belongs_to :asset
  belongs_to :currency
  belongs_to :partner_resource, optional: true

  # Validations
  validates :ticker_symbol, :price, :last_sync_at, :reference_date, :status, presence: true
  validate :partner_resource_presence, if: -> { asset.present? && !asset.custom }
  validates :asset_id, uniqueness: { scope: :partner_resource_id }

  # Scopes
  scope :updated, -> { where(status: :updated) }
  scope :scheduled, -> { where(status: :scheduled) }
  scope :processing, -> { where(status: :processing) }
  scope :failed, -> { where(status: :failed) }
  scope :pending, -> { where(status: :pending) }

  # AASM
  aasm column: :status do
    state :pending, initial: true
    state :scheduled
    state :processing
    state :updated
    state :failed

    event :schedule do
      transitions from: :pending, to: :scheduled
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

    event :reset_asset_price do
      transitions from: %i[failed updated], to: :pending
    end
  end

  private

  def partner_resource_presence
    errors.add(:partner_resource, 'must be present') if partner_resource.blank?
  end
end
