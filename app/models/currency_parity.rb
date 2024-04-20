class CurrencyParity < ApplicationRecord
  belongs_to :currency_from
  belongs_to :currency_to
end
