# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrencyParities::OutdatedError do
  subject(:error) { described_class.new(message) }

  let(:currency_parity) { create(:currency_parity) }
  let(:message) { "CurrencyParity with id: #{currency_parity.id} is outdated." }

  it 'inherits from StandardError' do
    expect(error).to be_a(StandardError)
  end

  it 'has a message' do
    expect(error.message).to eq("CurrencyParity with id: #{currency_parity.id} is outdated.")
  end
end
