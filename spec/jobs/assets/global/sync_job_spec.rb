# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Assets::Global::SyncJob, type: :job do
  describe 'sidekiq_options' do
    it 'sets the queue to assets_global_sync' do
      expect(described_class.get_sidekiq_options['queue']).to eq('assets_global_sync')
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
    subject(:assets_global_sync_job) { described_class.new.perform }

    before do
      allow(Rails.application.credentials).to receive(:hg_brasil).and_return({ request_delay_in_seconds: 4 })
    end

    context 'when there are no rebalance orders being processed' do
      let(:hg_brasil_stock_price) { create(:partner_resource, :hg_brasil_stock_price) }

      let(:mgl3) { create(:asset, ticker_symbol: 'MGLU3', name: 'Magazine Luiza') }
      let!(:mgl3_asset_price) do
        create(:asset_price,
               asset: mgl3,
               partner_resource: hg_brasil_stock_price,
               status: 'updated',
               ticker_symbol: 'MGLU3')
      end

      let(:vale3) { create(:asset, ticker_symbol: 'VALE3', name: 'Vale') }
      let!(:vale3_asset_price) do
        create(:asset_price,
               asset: vale3,
               partner_resource: hg_brasil_stock_price,
               status: 'updated',
               ticker_symbol: 'VALE3')
      end

      let(:hapv3) { create(:asset, ticker_symbol: 'HAPV3', name: 'Hapvida Participacoes E Investimentos Sa') }
      let!(:hapv3_asset_price) do
        create(:asset_price,
               asset: hapv3,
               partner_resource: hg_brasil_stock_price,
               status: 'updated',
               ticker_symbol: 'HAPV3')
      end

      let(:petr4) { create(:asset, ticker_symbol: 'PETR4', name: 'Petrobras') }
      let!(:petr4_asset_price) do
        create(:asset_price,
               asset: petr4,
               partner_resource: hg_brasil_stock_price,
               status: 'updated',
               ticker_symbol: 'PETR4')
      end

      let(:b3sa3) { create(:asset, ticker_symbol: 'B3SA3', name: 'B3') }
      let!(:b3sa3_asset_price) do
        create(:asset_price,
               asset: b3sa3,
               partner_resource: hg_brasil_stock_price,
               status: 'updated',
               ticker_symbol: 'B3SA3')
      end

      let(:bbdc4) { create(:asset, ticker_symbol: 'BBDC4', name: 'Banco Bradesco') }
      let!(:bbdc4_asset_price) do
        create(:asset_price,
               asset: bbdc4,
               partner_resource: hg_brasil_stock_price,
               status: 'updated',
               ticker_symbol: 'BBDC4')
      end

      let(:seql3) { create(:asset, ticker_symbol: 'SEQL3', name: 'Sequoia Logistica E Transportes Sa') }
      let!(:seql3_asset_price) do
        create(:asset_price,
               asset: seql3,
               partner_resource: hg_brasil_stock_price,
               status: 'updated',
               ticker_symbol: 'SEQL3')
      end

      let(:itsa4) { create(:asset, ticker_symbol: 'ITSA4', name: 'Itausa Investimentos Itau Sa') }
      let!(:itsa4_asset_price) do
        create(:asset_price,
               asset: itsa4,
               partner_resource: hg_brasil_stock_price,
               status: 'updated',
               ticker_symbol: 'ITSA4')
      end

      let(:abev3) { create(:asset, ticker_symbol: 'ABEV3', name: 'Ambev') }
      let!(:abev3_asset_price) do
        create(:asset_price,
               asset: abev3,
               partner_resource: hg_brasil_stock_price,
               status: 'updated',
               ticker_symbol: 'ABEV3')
      end

      let(:petz3) { create(:asset, ticker_symbol: 'PETZ3', name: 'Petz') }
      let!(:petz3_asset_price) do
        create(:asset_price,
               asset: petz3,
               partner_resource: hg_brasil_stock_price,
               status: 'updated',
               ticker_symbol: 'PETZ3')
      end

      let(:tasa4) { create(:asset, ticker_symbol: 'TASA4', name: 'Taurus Armas') }
      let!(:tasa4_asset_price) do
        create(:asset_price,
               asset: tasa4,
               partner_resource: hg_brasil_stock_price,
               status: 'failed',
               ticker_symbol: 'TASA4')
      end

      let(:btci11) { create(:asset, ticker_symbol: 'BTCI11', name: 'BTG Pactual Fundo de Fundos') }
      let!(:btci11_asset_price) do
        create(:asset_price,
               asset: btci11,
               partner_resource: hg_brasil_stock_price,
               status: 'scheduled',
               ticker_symbol: 'BTCI11')
      end

      let(:hglg11) { create(:asset, ticker_symbol: 'HGLG11', name: 'CSHG Logistica') }
      let!(:hglg11_asset_price) do
        create(:asset_price,
               asset: hglg11,
               partner_resource: hg_brasil_stock_price,
               status: 'processing',
               ticker_symbol: 'HGLG11')
      end

      before do
        allow(Assets::HgBrasil::SyncJob).to receive(:perform_in).with(0.seconds, 'MGLU3,VALE3,HAPV3,PETR4,B3SA3').and_return(true)
        allow(Assets::HgBrasil::SyncJob).to receive(:perform_in).with(4.seconds, 'BBDC4,SEQL3,ITSA4,ABEV3,PETZ3').and_return(true)
        assets_global_sync_job
      end

      it 'updates the asset prices' do
        expect(Assets::HgBrasil::SyncJob).to have_received(:perform_in).twice

        expect(tasa4_asset_price.reload).to be_failed
        expect(tasa4_asset_price.scheduled_at).to be_nil
        expect(btci11_asset_price.reload).to be_scheduled
        expect(hglg11_asset_price.reload).to be_processing

        [
          mgl3_asset_price,
          vale3_asset_price,
          hapv3_asset_price,
          petr4_asset_price,
          b3sa3_asset_price,
          bbdc4_asset_price,
          seql3_asset_price,
          itsa4_asset_price,
          abev3_asset_price,
          petz3_asset_price
        ].each do |asset_price|
          expect(asset_price.reload).to be_scheduled
          expect(asset_price.scheduled_at).to be_a(Time)
        end
      end
    end

    context 'when there are rebalance orders being processed' do
      before do
        allow(Assets::HgBrasil::SyncJob).to receive(:perform_async).and_call_original
        create(:rebalance_order, :processing)
      end

      it 'does not update the asset prices' do
        response = assets_global_sync_job

        expect(response).to be_nil
        expect(Assets::HgBrasil::SyncJob).not_to have_received(:perform_async)
      end
    end
  end
end
