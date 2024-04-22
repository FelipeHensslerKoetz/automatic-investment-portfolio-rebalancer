# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrencyParityMissingError do
  subject(:error) { described_class.new(currency_from:, currency_to:) }

  let(:currency_from) { create(:currency, :usd) }
  let(:currency_to) { create(:currency, :brl) }

  it 'inherits from StandardError' do
    expect(error).to be_a(StandardError)
  end

  it 'has a message' do
    expect(error.message).to eq("Missing CurrencyParity from #{currency_from.code} to #{currency_to.code}.")
  end

  it 'has a currency_from attribute' do
    expect(error.currency_from).to eq(currency_from)
  end

  it 'has a currency_to attribute' do
    expect(error.currency_to).to eq(currency_to)
  end
end
