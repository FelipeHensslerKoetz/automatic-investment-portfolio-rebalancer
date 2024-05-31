# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrencyParityMissingError do
  subject(:error) { described_class.new(message) }

  let(:currency_from) { create(:currency, :usd) }
  let(:currency_to) { create(:currency, :brl) }
  let(:message) { "Missing CurrencyParity from #{currency_from.code} to #{currency_to.code}." } 

  it 'inherits from StandardError' do
    expect(error).to be_a(StandardError)
  end

  it 'has a message' do
    expect(error.message).to eq("Missing CurrencyParity from #{currency_from.code} to #{currency_to.code}.")
  end
end
