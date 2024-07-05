# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Global::CurrencyParityExchangeRates::SyncJob, type: :job do
  describe 'sidekiq_options' do
    it 'sets the queue to global_currency_parity_exchange_rates_sync' do
      expect(described_class.get_sidekiq_options['queue']).to eq('global_currency_parity_exchange_rates_sync')
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

      let(:hg_brasil_quotation_partner_resource) { create(:partner_resource, :hg_brasil_quotation) }
      let(:br_api_currency_partner_resource) { create(:partner_resource, :br_api_currency) }

      let!(:hg_brasil_pending_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate, partner_resource: hg_brasil_quotation_partner_resource, status: 'pending')
      end
      let!(:hg_brasil_failed_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate, partner_resource: hg_brasil_quotation_partner_resource, status: 'failed')
      end
      let!(:hg_brasil_updated_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate, partner_resource: hg_brasil_quotation_partner_resource, status: 'updated')
      end
      let!(:hg_brasil_processing_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate, partner_resource: hg_brasil_quotation_partner_resource, status: 'processing')
      end
      let!(:hg_brasil_scheduled_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate, partner_resource: hg_brasil_quotation_partner_resource, status: 'scheduled')
      end

      let!(:br_api_pending_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate, partner_resource: br_api_currency_partner_resource, status: 'pending')
      end
      let!(:br_api_failed_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate, partner_resource: br_api_currency_partner_resource, status: 'failed')
      end
      let!(:br_api_updated_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate, partner_resource: br_api_currency_partner_resource, status: 'updated')
      end
      let!(:br_api_processing_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate, partner_resource: br_api_currency_partner_resource, status: 'processing')
      end
      let!(:br_api_scheduled_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate, partner_resource: br_api_currency_partner_resource, status: 'scheduled')
      end

      before do
        allow(HgBrasil::CurrencyParityExchangeRates::SyncJob).to receive(:perform_async).and_return(true)
        allow(BrApi::CurrencyParityExchangeRates::SyncJob).to receive(:perform_in).with(
          0.seconds, br_api_pending_currency_parity_exchange_rate.currency_parity.currency_from.code,
          br_api_pending_currency_parity_exchange_rate.currency_parity.currency_to.code
        ).and_return(true)
        global_sync_job.perform
      end

      it 'calls HgBrasil::CurrencyParityExchangeRates::SyncJob.perform_async' do
        expect(HgBrasil::CurrencyParityExchangeRates::SyncJob).to have_received(:perform_async).once
        expect(hg_brasil_updated_currency_parity_exchange_rate.reload).to be_updated
        expect(hg_brasil_failed_currency_parity_exchange_rate.reload).to be_failed
        expect(hg_brasil_processing_currency_parity_exchange_rate.reload).to be_processing
        expect(hg_brasil_scheduled_currency_parity_exchange_rate.reload).to be_scheduled
        expect(hg_brasil_pending_currency_parity_exchange_rate.reload).to be_scheduled

        expect(BrApi::CurrencyParityExchangeRates::SyncJob).to have_received(:perform_in).with(0.seconds, br_api_pending_currency_parity_exchange_rate.currency_parity.currency_from.code,
                                                                                               br_api_pending_currency_parity_exchange_rate.currency_parity.currency_to.code).once
        expect(br_api_updated_currency_parity_exchange_rate.reload).to be_updated
        expect(br_api_failed_currency_parity_exchange_rate.reload).to be_failed
        expect(br_api_processing_currency_parity_exchange_rate.reload).to be_processing
        expect(br_api_scheduled_currency_parity_exchange_rate.reload).to be_scheduled
        expect(br_api_pending_currency_parity_exchange_rate.reload).to be_scheduled
      end
    end
  end
end
