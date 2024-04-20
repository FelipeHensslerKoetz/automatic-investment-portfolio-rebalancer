class PartnerResource < ApplicationRecord
  # Constants
  INTEGRATED_PARTNER_RESOURCES = [
    :hg_brasil
  ].freeze

  # Associations
  belongs_to :partner

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, inclusion: { in: INTEGRATED_PARTNER_RESOURCES.map(&:to_s) }
end
