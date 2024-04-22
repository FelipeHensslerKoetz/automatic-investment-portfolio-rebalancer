# frozen_string_literal: true

class CurrencyParityOutdatedError < StandardError
  attr_reader :currency_parity

  def initialize(currency_parity:)
    @currency_parity = currency_parity
    super("CurrencyParity with id: #{currency_parity.id} is outdated.")
  end
end
