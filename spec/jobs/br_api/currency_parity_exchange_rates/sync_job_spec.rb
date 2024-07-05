# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrApi::CurrencyParityExchangeRates::SyncJob, type: :job do
  describe 'sidekiq_options' do
    it 'sets the queue to br_api_currency_parity_exchange_rates_sync' do
      expect(described_class.get_sidekiq_options['queue']).to eq('br_api_currency_parity_exchange_rates_sync')
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
    subject(:br_api_sync_job) { described_class.new }

    let(:currency_from_code) { 'USD' }
    let(:currency_to_code) { 'BRL' }

    before do
      allow(BrApi::CurrencyParityExchangeRates::SyncService).to receive(:call).with(currency_from_code:, currency_to_code:).and_return(true)
      br_api_sync_job.perform(currency_from_code, currency_to_code)
    end

    it 'calls BrApi::CurrencyParityExchangeRates::SyncService' do
      expect(BrApi::CurrencyParityExchangeRates::SyncService).to have_received(:call).with(currency_from_code:, currency_to_code:).once
    end
  end
end
