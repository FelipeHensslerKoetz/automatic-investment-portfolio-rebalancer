# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrencyParityOutdatedError do
  subject(:error) { described_class.new(currency_parity:) }

  let(:currency_parity) { create(:currency_parity) }

  it 'inherits from StandardError' do
    expect(error).to be_a(StandardError)
  end

  it 'has a message' do
    expect(error.message).to eq("CurrencyParity with id: #{currency_parity.id} is outdated.")
  end

  it 'has a currency_parity attribute' do
    expect(error.currency_parity).to eq(currency_parity)
  end
end
