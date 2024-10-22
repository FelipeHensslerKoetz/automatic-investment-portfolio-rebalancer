require 'rails_helper'

RSpec.describe System::Rebalances::RebalanceOrderValidationService do
  describe '.call' do
    subject(:rebalance_order_validation_service) { described_class.call(rebalance_order:) }

    context 'when the rebalance order is valid' do
      let(:rebalance_order) { create(:rebalance_order, :default, :scheduled) }

      it 'does not raise an error' do
        expect { rebalance_order_validation_service }.not_to raise_error
      end
    end

    context 'when the rebalance order is invalid' do
      context 'when the rebalance order is invalid' do
        let(:rebalance_order) { nil }

        it 'raises an error' do
          expect { rebalance_order_validation_service }.to raise_error(NoMethodError)
        end
      end

      context 'when the rebalance order status is not scheduled' do
        let(:rebalance_order) { create(:rebalance_order, :default, :succeed) }

        it 'raises an error' do
          expect { rebalance_order_validation_service }.to raise_error(RebalanceOrders::InvalidStatusError)
        end
      end
    end
  end
end
