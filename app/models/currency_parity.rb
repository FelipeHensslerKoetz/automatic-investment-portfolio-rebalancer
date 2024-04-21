# frozen_string_literal: true

class CurrencyParity < ApplicationRecord
  # Relationships
  belongs_to :currency_from, class_name: 'Currency',
                             inverse_of: :currency_parities_as_from
  belongs_to :currency_to, class_name: 'Currency',
                           inverse_of: :currency_parities_as_to

  has_many :currency_parity_exchange_rates, dependent: :restrict_with_error

  # Methods
  def updated?
    currency_parity_exchange_rates.updated.any?
  end

  def latest_currency_parity_exchange_rate
    return unless updated?

    currency_parity_exchange_rates.updated.order(reference_date: :desc).first
  end
end
