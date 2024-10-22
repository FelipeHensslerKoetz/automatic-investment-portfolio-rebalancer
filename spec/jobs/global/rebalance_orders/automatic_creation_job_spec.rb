# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Global::RebalanceOrders::AutomaticCreationJob, type: :job do
  describe 'sidekiq_options' do
    it 'sets the queue to global_rebalance_orders_automatic_creation' do
      expect(described_class.get_sidekiq_options['queue']).to eq('global_rebalance_orders_automatic_creation')
    end

    it 'sets the retry option to false' do
      expect(described_class.get_sidekiq_options['retry']).to eq(false)
    end
  end

  describe 'includes' do
    it 'includes Sidekiq::Job' do
      expect(described_class.ancestors).to include(Sidekiq::Job)
    end
  end

  describe '#perform' do
    subject(:global_rebalance_orders_automatic_creation_job) { described_class.new }

    let!(:first_recurrence_automatic_rebalance_option) { create(:automatic_rebalance_option, :recurrence) }
    let!(:second_recurrence_automatic_rebalance_option) { create(:automatic_rebalance_option, :recurrence) }

    let!(:first_variation_automatic_rebalance_option) { create(:automatic_rebalance_option, :variation) }
    let!(:second_variation_automatic_rebalance_option) { create(:automatic_rebalance_option, :variation) }

    before do
      allow(Global::RebalanceOrders::AutomaticRebalanceByRecurrenceService).to receive(:call).with(
        automatic_rebalance_option: first_recurrence_automatic_rebalance_option
      ).and_return(true)
      allow(Global::RebalanceOrders::AutomaticRebalanceByRecurrenceService).to receive(:call).with(
        automatic_rebalance_option: second_recurrence_automatic_rebalance_option
      ).and_return(true)
      allow(Global::RebalanceOrders::AutomaticRebalanceByVariationService).to receive(:call).with(
        automatic_rebalance_option: first_variation_automatic_rebalance_option
      ).and_return(true)
      allow(Global::RebalanceOrders::AutomaticRebalanceByVariationService).to receive(:call).with(
        automatic_rebalance_option: second_variation_automatic_rebalance_option
      ).and_return(true)
    end

    it 'calls the respective service for each automatic rebalance option' do
      global_rebalance_orders_automatic_creation_job.perform

      expect(Global::RebalanceOrders::AutomaticRebalanceByRecurrenceService).to have_received(:call).with(
        automatic_rebalance_option: first_recurrence_automatic_rebalance_option
      )
      expect(Global::RebalanceOrders::AutomaticRebalanceByRecurrenceService).to have_received(:call).with(
        automatic_rebalance_option: second_recurrence_automatic_rebalance_option
      )
      expect(Global::RebalanceOrders::AutomaticRebalanceByVariationService).to have_received(:call).with(
        automatic_rebalance_option: first_variation_automatic_rebalance_option
      )
      expect(Global::RebalanceOrders::AutomaticRebalanceByVariationService).to have_received(:call).with(
        automatic_rebalance_option: second_variation_automatic_rebalance_option
      )
    end
  end
end
