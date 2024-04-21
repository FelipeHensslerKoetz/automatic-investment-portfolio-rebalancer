# frozen_string_literal: true

class Currency < ApplicationRecord
  # Relationships
  has_many :currency_parities_as_from,
           class_name: 'CurrencyParity',
           foreign_key: 'from_currency_id',
           inverse_of: :currency_from,
           dependent: :restrict_with_error

  has_many :currency_parities_as_to,
           class_name: 'CurrencyParity',
           foreign_key: 'to_currency_id',
           inverse_of: :currency_to,
           dependent: :restrict_with_error

  # Validations
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
