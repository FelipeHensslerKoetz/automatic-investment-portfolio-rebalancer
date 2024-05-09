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

  def self.find(search_term)
    record = if search_term.to_i.to_s == search_term.to_s
               find_by(id: search_term)
             else
               find_by(ticker_symbol: search_term.upcase)
             end

    raise ActiveRecord::RecordNotFound, "Couldn't find #{name} with '#{search_term}'" if record.nil?

    record
  end
end
