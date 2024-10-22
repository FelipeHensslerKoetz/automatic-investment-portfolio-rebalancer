# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RebalanceOrders::InvalidStatusError do
  let(:rebalance_order) { create(:rebalance_order, :default, status: 'succeed') }

  subject { described_class.new(rebalance_order:) }

  describe '#rebalance_order' do
    it 'returns the rebalance_order' do
      expect(subject.rebalance_order).to eq(rebalance_order)
    end
  end

  describe '#message' do
    it 'returns the error message' do
      expect(subject.message).to eq("Expecting pending status for RebalanceOrder with id #{rebalance_order.id}, " \
                                    "got #{rebalance_order.status} status.")
    end
  end
end
