# frozen_string_literal: true

class PartnerResource < ApplicationRecord
  # Constants
  INTEGRATED_PARTNER_RESOURCES = %i[
    hg_brasil_stock_price
    hg_brasil_quotation
    br_api_quotation
  ].freeze

  # Associations
  belongs_to :partner

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, inclusion: { in: INTEGRATED_PARTNER_RESOURCES.map(&:to_s) }
end
