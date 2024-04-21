# frozen_string_literal: true

class Asset < ApplicationRecord
  # Constants
  ASSET_KINDS = %i[
    stock
    etf
    mutual_fund
    fii
  ].freeze

  # Associations
  belongs_to :user, optional: true
  has_many :asset_prices, dependent: :restrict_with_error

  # Validations
  validates :name, :ticker_symbol, presence: true
  validates :ticker_symbol, uniqueness: true
  validates :custom, inclusion: { in: [true, false] }
  validates :kind, inclusion: { in: ASSET_KINDS.map(&:to_s) }

  # Scopes
  scope :global, -> { where(custom: false) }
  scope :custom_by_user, ->(user) { where(custom: true, user:) }

  def updated?
    asset_prices.updated.any?
  end

  def newest_asset_price_by_reference_date
    return unless updated?

    asset_prices.updated.order(reference_date: :desc).first
  end
end
