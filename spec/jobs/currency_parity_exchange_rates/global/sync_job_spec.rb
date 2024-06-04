# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrencyParityExchangeRates::Global::SyncJob, type: :job do
  describe 'sidekiq_options' do
    it 'sets the queue to currency_parity_exchange_rates_global_sync' do
      expect(described_class.get_sidekiq_options['queue']).to eq('currency_parity_exchange_rates_global_sync')
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
    context 'when there is no rebalance order being processed' do
      subject(:global_sync_job) { described_class.new }

      let!(:failed_currency_parity_exchange_rate) { create(:currency_parity_exchange_rate, partner_resource:, status: 'failed') }
      let!(:updated_currency_parity_exchange_rate) { create(:currency_parity_exchange_rate, partner_resource:, status: 'updated') }
      let!(:processing_currency_parity_exchange_rate) { create(:currency_parity_exchange_rate, partner_resource:, status: 'processing') }
      let!(:scheduled_currency_parity_exchange_rate) { create(:currency_parity_exchange_rate, partner_resource:, status: 'scheduled') }
      let(:partner_resource) { create(:partner_resource, :hg_brasil_quotation) }

      before do
        allow(CurrencyParityExchangeRates::HgBrasil::SyncJob).to receive(:perform_async)
        global_sync_job.perform
      end

      it 'calls CurrencyParityExchangeRates::HgBrasil::SyncJob.perform_async' do
        expect(CurrencyParityExchangeRates::HgBrasil::SyncJob).to have_received(:perform_async).once
        expect(updated_currency_parity_exchange_rate.reload).to be_scheduled
        expect(failed_currency_parity_exchange_rate.reload).to be_failed
        expect(processing_currency_parity_exchange_rate.reload).to be_processing
        expect(scheduled_currency_parity_exchange_rate.reload).to be_scheduled
      end
    end
  end
end
