# frozen_string_literal: true

class Partner < ApplicationRecord
  INTEGRATED_PARTNERS = [
    :hg_brasil,
    :br_api
  ].freeze

  # Associations
  has_many :partner_resources, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
end
