require 'rails_helper'

RSpec.describe Global::RebalanceOrders::ProcessJob, type: :job do
  describe 'sidekiq_options' do
    it 'has the sidekiq_options set' do
      expect(described_class.sidekiq_options).to eq(
        'queue' => 'global_rebalance_orders_process',
        'retry' => false
      )
    end
  end

  describe 'include' do
    it 'includes Sidekiq::Job' do
      expect(described_class.ancestors).to include(Sidekiq::Job)
    end
  end

  describe '#perform' do
    subject(:process_job) { described_class.new }

    context 'when there is no asset price or currency parity exchange rate being updated' do
      let!(:pending_rebalance_order) { create(:rebalance_order, scheduled_at: Time.zone.today, status: 'pending') }
      let!(:pending_rebalance_order_without_schedule) { create(:rebalance_order, scheduled_at: Time.zone.today + 1.day, status: 'pending') }
      let!(:processing_rebalance_order) { create(:rebalance_order, scheduled_at: Time.zone.today, status: 'processing') }
      let!(:processing_rebalance_order_without_schedule) { create(:rebalance_order, scheduled_at: Time.zone.today + 1.day, status: 'processing') }
      let!(:scheduled_rebalance_order) { create(:rebalance_order, scheduled_at: Time.zone.today, status: 'scheduled') }
      let!(:scheduled_rebalance_order_without_schedule) { create(:rebalance_order, scheduled_at: Time.zone.today + 1.day, status: 'scheduled') }
      let!(:succeed_rebalance_order) { create(:rebalance_order, scheduled_at: Time.zone.today, status: 'succeed') }
      let!(:succeed_rebalance_order_without_schedule) { create(:rebalance_order, scheduled_at: Time.zone.today + 1.day, status: 'succeed') }
      let!(:failed_rebalance_order) { create(:rebalance_order, scheduled_at: Time.zone.today, status: 'failed') }
      let!(:failed_rebalance_order_without_schedule) { create(:rebalance_order, scheduled_at: Time.zone.today + 1.day, status: 'failed') }
      let!(:pending_rebalance_order_scheduled_to_tomorrow) { create(:rebalance_order, scheduled_at: Time.zone.today + 1.day,
                                                                    status: 'pending') }

      before do 
        allow(System::Rebalances::CalculatorService).to receive(:call).with(rebalance_order_id: pending_rebalance_order.id).and_return(true)
      end

      it 'processes the rebalances with scheduled_at = Time.zone.today' do 
        process_job.perform
        expect(pending_rebalance_order.reload.status).to eq('scheduled')
        expect(System::Rebalances::CalculatorService).to have_received(:call).with(rebalance_order_id: pending_rebalance_order.id).once
      end
    end

    context 'when there is asset price or currency parity exchange rate being updated' do
      let!(:pending_rebalance_order) { create(:rebalance_order, scheduled_at: Time.zone.today, status: 'pending') }

      context 'when there is a scheduled currency parity exchange rate' do
        before do 
          create(:currency_parity_exchange_rate, :with_br_api_currencies_partner_resource, status: 'scheduled')
        end

        it 'does not process the rebalances' do
          process_job.perform
          expect(pending_rebalance_order.reload.status).to eq('pending')
        end
      end

      context 'when there is a processing currency parity exchange rate' do
        before do 
          create(:currency_parity_exchange_rate, :with_br_api_currencies_partner_resource, status: 'processing')
        end

        it 'does not process the rebalances' do
          process_job.perform
          expect(pending_rebalance_order.reload.status).to eq('pending')
        end
      end

      context 'when there is a scheduled asset price' do
        before do
          create(:asset_price, :with_br_api_assets_partner_resource, status: 'scheduled')
        end

        it 'does not process the rebalances' do
          process_job.perform
          expect(pending_rebalance_order.reload.status).to eq('pending')
        end
      end

      context 'when there is a processing asset price' do
        before do
          create(:asset_price, :with_br_api_assets_partner_resource, status: 'processing')
        end

        it 'does not process the rebalances' do
          process_job.perform
          expect(pending_rebalance_order.reload.status).to eq('pending')
        end
      end
    end
  end
end