# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rebalance, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:rebalance_order) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:before_state) }
    it { is_expected.to validate_presence_of(:after_state) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:details) }
    it { is_expected.to validate_presence_of(:recommended_actions) }
  end

  describe 'scopes' do
    describe '.pending' do
      let!(:rebalance) { create(:rebalance, :pending) }
      let!(:rebalance_processing) { create(:rebalance, :processing) }

      it 'returns rebalances with status pending' do
        expect(described_class.pending).to eq([rebalance])
      end
    end

    describe '.processing' do
      let!(:rebalance) { create(:rebalance, :processing) }
      let!(:rebalance_pending) { create(:rebalance, :pending) }

      it 'returns rebalances with status processing' do
        expect(described_class.processing).to eq([rebalance])
      end
    end

    describe '.succeed' do
      let!(:rebalance) { create(:rebalance, :succeed) }
      let!(:rebalance_pending) { create(:rebalance, :pending) }

      it 'returns rebalances with status succeed' do
        expect(described_class.succeed).to eq([rebalance])
      end
    end

    describe '.failed' do
      let!(:rebalance) { create(:rebalance, :failed) }
      let!(:rebalance_pending) { create(:rebalance, :pending) }

      it 'returns rebalances with status failed' do
        expect(described_class.failed).to eq([rebalance])
      end
    end
  end

  describe 'aasm' do
    it { is_expected.to have_state(:pending) }
    it { is_expected.to transition_from(:pending).to(:processing).on_event(:process) }
    it { is_expected.to transition_from(:processing).to(:succeed).on_event(:success) }
    it { is_expected.to transition_from(:processing).to(:failed).on_event(:fail) }
    it { is_expected.to transition_from(:failed).to(:processing).on_event(:process) }
  end
end
