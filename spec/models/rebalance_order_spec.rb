require 'rails_helper'

RSpec.describe RebalanceOrder, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:investment_portfolio) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:type) }
    it {
      is_expected.to validate_inclusion_of(:type).in_array(%w[default deposit
                                                              withdraw])
    }
  end

  describe 'scopes' do
    describe '.scheduled' do
      it 'returns scheduled rebalance orders' do
        scheduled_rebalance_order = create(:rebalance_order, status: 'scheduled')
        create(:rebalance_order, status: 'processing')
        expect(RebalanceOrder.scheduled.count).to eq(1)
        expect(RebalanceOrder.scheduled).to include(scheduled_rebalance_order)
      end
    end

    describe '.processing' do
      it 'returns processing rebalance orders' do
        processing_rebalance_order = create(:rebalance_order, status: 'processing')
        create(:rebalance_order, status: 'scheduled')
        expect(RebalanceOrder.processing.count).to eq(1)
        expect(RebalanceOrder.processing).to include(processing_rebalance_order)
      end
    end

    describe '.finished' do
      it 'returns finished rebalance orders' do
        finished_rebalance_order = create(:rebalance_order, status: 'finished')
        create(:rebalance_order, status: 'scheduled')
        expect(RebalanceOrder.finished.count).to eq(1)
        expect(RebalanceOrder.finished).to include(finished_rebalance_order)
      end
    end

    describe '.failed' do
      it 'returns failed rebalance orders' do
        failed_rebalance_order = create(:rebalance_order, status: 'failed')
        create(:rebalance_order, status: 'scheduled')
        expect(RebalanceOrder.failed.count).to eq(1)
        expect(RebalanceOrder.failed).to include(failed_rebalance_order)
      end
    end
  end

  describe 'aasm' do
    it { is_expected.to have_state(:scheduled) }
    it { is_expected.to transition_from(:scheduled).to(:processing).on_event(:process) }
    it { is_expected.to transition_from(:processing).to(:finished).on_event(:finish) }
    it { is_expected.to transition_from(:processing).to(:failed).on_event(:fail) }
    it { is_expected.to transition_from(:failed).to(:scheduled).on_event(:schedule) }
  end
end
