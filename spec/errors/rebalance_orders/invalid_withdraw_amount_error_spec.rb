# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RebalanceOrders::InvalidWithdrawAmountError do
  subject { described_class.new('Invalid withdraw amount') }

  describe '#message' do
    it 'returns the error message' do
      expect(subject.message).to eq('Invalid withdraw amount')
    end
  end
end
