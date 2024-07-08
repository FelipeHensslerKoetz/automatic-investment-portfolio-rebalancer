# frozen_string_literal: true

class PartnerResource < ApplicationRecord
  # Constants
  INTEGRATED_PARTNER_RESOURCES = %i[
    hg_brasil_assets
    hg_brasil_currencies
    br_api_assets
    br_api_currencies
  ].freeze

  # Associations
  belongs_to :partner

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, inclusion: { in: INTEGRATED_PARTNER_RESOURCES.map(&:to_s) }
end
