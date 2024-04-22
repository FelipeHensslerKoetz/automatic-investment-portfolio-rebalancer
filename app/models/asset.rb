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

  # Methods
  def newest_asset_price_by_reference_date
    asset_prices.order(reference_date: :desc).first
  end

  # TODO: amplify this method to consider priority of asset_prices partner_resources
  def current_price
    return nil if newest_asset_price_by_reference_date.blank?

    newest_asset_price_by_reference_date.price
  end
end
