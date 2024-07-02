# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HgBrasil::Assets::SyncJob, type: :job do
  describe 'sidekiq_options' do
    it 'sets the queue to price_sync_hg_brasil_batch' do
      expect(described_class.get_sidekiq_options['queue']).to eq('hg_brasil_assets_sync')
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
    subject(:batch_job) { described_class.new }

    let(:ticker_symbols) { 'symbol1,symbol2,symbol3,symbol4,symbol5' }
    let(:sync_service_instance) { instance_double(HgBrasil::Assets::SyncService, call: true) }

    before do
      allow(HgBrasil::Assets::SyncService).to receive(:new).and_return(sync_service_instance)
      batch_job.perform(ticker_symbols)
    end

    it 'calls HgBrasil::Assets::SyncService.new with the ticker_symbols' do
      expect(HgBrasil::Assets::SyncService).to have_received(:new).with(ticker_symbols:).once
      expect(sync_service_instance).to have_received(:call).once
    end
  end
end
