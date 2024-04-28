# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RebalanceOrder, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:investment_portfolio) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:kind) }
    it {
      is_expected.to validate_inclusion_of(:kind).in_array(RebalanceOrder::REBALANCE_ORDER_KINDS)
    }
  end

  describe 'scopes' do
    let!(:pending_rebalance_order) { create(:rebalance_order, status: 'pending') }
    let!(:scheduled_rebalance_order) { create(:rebalance_order, status: 'scheduled') }
    let!(:processing_rebalance_order) { create(:rebalance_order, status: 'processing') }
    let!(:succeed_rebalance_order) { create(:rebalance_order, status: 'succeed') }
    let!(:failed_rebalance_order) { create(:rebalance_order, status: 'failed') }

    describe '.pending' do
      it 'returns pending rebalance orders' do
        expect(RebalanceOrder.pending.count).to eq(1)
        expect(RebalanceOrder.pending).to include(pending_rebalance_order)
      end
    end

    describe '.processing' do
      it 'returns processing rebalance orders' do
        expect(RebalanceOrder.processing.count).to eq(1)
        expect(RebalanceOrder.processing).to include(processing_rebalance_order)
      end
    end

    describe '.succeed' do
      it 'returns succeed rebalance orders' do
        expect(RebalanceOrder.succeed.count).to eq(1)
        expect(RebalanceOrder.succeed).to include(succeed_rebalance_order)
      end
    end

    describe '.failed' do
      it 'returns failed rebalance orders' do
        expect(RebalanceOrder.failed.count).to eq(1)
        expect(RebalanceOrder.failed).to include(failed_rebalance_order)
      end
    end

    describe '.scheduled' do
      it 'returns scheduled rebalance orders' do
        expect(RebalanceOrder.scheduled.count).to eq(1)
        expect(RebalanceOrder.scheduled).to include(scheduled_rebalance_order)
      end
    end
  end

  describe 'aasm' do
    it { is_expected.to have_state(:pending) }
    it { is_expected.to transition_from(:pending).to(:scheduled).on_event(:schedule) }
    it { is_expected.to transition_from(:scheduled).to(:processing).on_event(:process) }
    it { is_expected.to transition_from(:processing).to(:succeed).on_event(:success) }
    it { is_expected.to transition_from(:processing).to(:failed).on_event(:fail) }
    it { is_expected.to transition_from(:failed).to(:pending).on_event(:retry) }
  end
end
