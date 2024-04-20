class CurrencyParityExchangeRate < ApplicationRecord
  belongs_to :currency_parity
  belongs_to :partner_resource
end
