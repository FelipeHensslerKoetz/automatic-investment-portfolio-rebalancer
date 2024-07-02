# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HgBrasil::CurrencyParityExchangeRates::SyncJob, type: :job do
  describe 'sidekiq_options' do
    it 'sets the queue to hg_brasil_currency_parity_exchange_rates_sync' do
      expect(described_class.get_sidekiq_options['queue']).to eq('hg_brasil_currency_parity_exchange_rates_sync')
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
    subject(:hg_brasil_sync_job) { described_class.new }

    before do
      allow(HgBrasil::CurrencyParityExchangeRates::SyncService).to receive(:call).and_return(true)
      hg_brasil_sync_job.perform
    end

    it 'calls HgBrasil::CurrencyParityExchangeRates::SyncService.new' do
      expect(HgBrasil::CurrencyParityExchangeRates::SyncService).to have_received(:call).once
    end
  end
end
