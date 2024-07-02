# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Global::Assets::DiscoveryJob, type: :job do
  describe 'sidekiq_options' do
    it 'sets the queue to global_assets_discovery' do
      expect(described_class.get_sidekiq_options['queue']).to eq('global_assets_discovery')
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
    subject(:asset_discovery_job) { described_class.new }

    let(:asset_discovery_global_instance) { instance_double(Global::Assets::DiscoveryService, call: true) }
    let(:keywords) { 'keyword' }

    before do
      allow(Global::Assets::DiscoveryService).to receive(:new).and_return(asset_discovery_global_instance)
      asset_discovery_job.perform(keywords)
    end

    it 'calls  Global::Assets::DiscoveryService.new with the keywords' do
      expect(Global::Assets::DiscoveryService).to have_received(:new).with(keywords:).once
      expect(asset_discovery_global_instance).to have_received(:call).once
    end
  end
end
