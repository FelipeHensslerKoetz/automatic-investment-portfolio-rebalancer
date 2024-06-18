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

  def self.find(search_term)
    record = if search_term.to_i.to_s == search_term.to_s
               find_by(id: search_term)
             else
               find_by(code: search_term.upcase)
             end

    raise ActiveRecord::RecordNotFound, "Couldn't find #{name} with '#{search_term}'" if record.nil?

    record
  end

  def self.default_currency
    Currency.find_by!(code: 'BRL')
  end
end
