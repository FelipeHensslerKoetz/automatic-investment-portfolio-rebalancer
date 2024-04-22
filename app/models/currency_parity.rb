# frozen_string_literal: true

class CurrencyParity < ApplicationRecord
  # Relationships
  belongs_to :currency_from, class_name: 'Currency',
                             inverse_of: :currency_parities_as_from
  belongs_to :currency_to, class_name: 'Currency',
                           inverse_of: :currency_parities_as_to

  has_many :currency_parity_exchange_rates, dependent: :restrict_with_error

  def newest_currency_parity_exchange_rate_by_reference_date
    currency_parity_exchange_rates.updated.order(reference_date: :desc).first
  end

  def current_exchange_rate
    return nil if newest_currency_parity_exchange_rate_by_reference_date.blank?

    newest_currency_parity_exchange_rate_by_reference_date.exchange_rate
  end
end
