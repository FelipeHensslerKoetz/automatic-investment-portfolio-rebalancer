# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Global::Assets::SyncJob, type: :job do
  describe 'sidekiq_options' do
    it 'sets the queue to global_assets_sync' do
      expect(described_class.get_sidekiq_options['queue']).to eq('global_assets_sync')
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
      allow(Rails.application.credentials).to receive(:br_api).and_return({ request_delay_in_seconds: 4 })
    end

    context 'when there are no rebalance orders being processed' do
      let(:hg_brasil_assets_partner_resource) { create(:partner_resource, :hg_brasil_assets) }
      let(:br_api_assets_partner_resource) { create(:partner_resource, :br_api_assets) }

      let(:mgl3) { create(:asset, ticker_symbol: 'MGLU3', name: 'Magazine Luiza') }
      let!(:mgl3_hg_brasil_asset_price) do
        create(:asset_price,
               asset: mgl3,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'MGLU3')
      end
      let!(:mgl3_br_api_asset_price) do
        create(:asset_price,
               asset: mgl3,
               partner_resource: br_api_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'MGLU3')
      end

      let(:vale3) { create(:asset, ticker_symbol: 'VALE3', name: 'Vale') }
      let!(:vale3_hg_brasil_asset_price) do
        create(:asset_price,
               asset: vale3,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'VALE3')
      end
      let!(:vale3_br_api_asset_price) do
        create(:asset_price,
               asset: vale3,
               partner_resource: br_api_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'VALE3')
      end

      let(:hapv3) { create(:asset, ticker_symbol: 'HAPV3', name: 'Hapvida Participacoes E Investimentos Sa') }
      let!(:hapv3_hg_brasil_asset_price) do
        create(:asset_price,
               asset: hapv3,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'HAPV3')
      end
      let!(:hapv3_br_api_asset_price) do
        create(:asset_price,
               asset: hapv3,
               partner_resource: br_api_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'HAPV3')
      end

      let(:petr4) { create(:asset, ticker_symbol: 'PETR4', name: 'Petrobras') }
      let!(:petr4_hg_brasil_asset_price) do
        create(:asset_price,
               asset: petr4,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'PETR4')
      end
      let!(:petr4_br_api_asset_price) do
        create(:asset_price,
               asset: petr4,
               partner_resource: br_api_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'PETR4')
      end

      let(:b3sa3) { create(:asset, ticker_symbol: 'B3SA3', name: 'B3') }
      let!(:b3sa3_hg_brasil_asset_price) do
        create(:asset_price,
               asset: b3sa3,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'B3SA3')
      end
      let!(:b3sa3_br_api_asset_price) do
        create(:asset_price,
               asset: b3sa3,
               partner_resource: br_api_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'B3SA3')
      end

      let(:bbdc4) { create(:asset, ticker_symbol: 'BBDC4', name: 'Banco Bradesco') }
      let!(:bbdc4_hg_brasil_asset_price) do
        create(:asset_price,
               asset: bbdc4,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'BBDC4')
      end
      let!(:bbdc4_br_api_asset_price) do
        create(:asset_price,
               asset: bbdc4,
               partner_resource: br_api_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'BBDC4')
      end

      let(:seql3) { create(:asset, ticker_symbol: 'SEQL3', name: 'Sequoia Logistica E Transportes Sa') }
      let!(:seql3_hg_brasil_asset_price) do
        create(:asset_price,
               asset: seql3,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'SEQL3')
      end
      let!(:seql3_br_api_asset_price) do
        create(:asset_price,
               asset: seql3,
               partner_resource: br_api_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'SEQL3')
      end

      let(:itsa4) { create(:asset, ticker_symbol: 'ITSA4', name: 'Itausa Investimentos Itau Sa') }
      let!(:itsa4_hg_brasil_asset_price) do
        create(:asset_price,
               asset: itsa4,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'ITSA4')
      end
      let!(:itsa4_br_api_asset_price) do
        create(:asset_price,
               asset: itsa4,
               partner_resource: br_api_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'ITSA4')
      end

      let(:abev3) { create(:asset, ticker_symbol: 'ABEV3', name: 'Ambev') }
      let!(:abev3_hg_brasil_asset_price) do
        create(:asset_price,
               asset: abev3,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'ABEV3')
      end
      let!(:abev3_br_api_asset_price) do
        create(:asset_price,
               asset: abev3,
               partner_resource: br_api_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'ABEV3')
      end

      let(:petz3) { create(:asset, ticker_symbol: 'PETZ3', name: 'Petz') }
      let!(:petz3_hg_brasil_asset_price) do
        create(:asset_price,
               asset: petz3,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'PETZ3')
      end
      let!(:petz3_br_api_asset_price) do
        create(:asset_price,
               asset: petz3,
               partner_resource: br_api_assets_partner_resource,
               status: 'pending',
               ticker_symbol: 'PETZ3')
      end

      let(:tasa4) { create(:asset, ticker_symbol: 'TASA4', name: 'Taurus Armas') }
      let!(:tasa4_hg_brasil_asset_price) do
        create(:asset_price,
               asset: tasa4,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'failed',
               ticker_symbol: 'TASA4')
      end
      let!(:tasa4_br_api_asset_price) do
        create(:asset_price,
               asset: tasa4,
               partner_resource: br_api_assets_partner_resource,
               status: 'failed',
               ticker_symbol: 'TASA4')
      end

      let(:btci11) { create(:asset, ticker_symbol: 'BTCI11', name: 'BTG Pactual Fundo de Fundos') }
      let!(:btci11_hg_brasil_asset_price) do
        create(:asset_price,
               asset: btci11,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'scheduled',
               ticker_symbol: 'BTCI11')
      end
      let!(:btci11_br_api_asset_price) do
        create(:asset_price,
               asset: btci11,
               partner_resource: br_api_assets_partner_resource,
               status: 'scheduled',
               ticker_symbol: 'BTCI11')
      end

      let(:hglg11) { create(:asset, ticker_symbol: 'HGLG11', name: 'CSHG Logistica') }
      let!(:hglg11_hg_brasil_asset_price) do
        create(:asset_price,
               asset: hglg11,
               partner_resource: hg_brasil_assets_partner_resource,
               status: 'processing',
               ticker_symbol: 'HGLG11')
      end
      let!(:hglg11_br_api_asset_price) do
        create(:asset_price,
               asset: hglg11,
               partner_resource: br_api_assets_partner_resource,
               status: 'processing',
               ticker_symbol: 'HGLG11')
      end

      before do
        allow(HgBrasil::Assets::SyncJob).to receive(:perform_in).with(0.seconds, 'MGLU3,VALE3,HAPV3,PETR4,B3SA3').and_return(true)
        allow(HgBrasil::Assets::SyncJob).to receive(:perform_in).with(4.seconds, 'BBDC4,SEQL3,ITSA4,ABEV3,PETZ3').and_return(true)
        allow(HgBrasil::Assets::SyncJob).to receive(:perform_in).with(8.seconds, 'TASA4').and_return(true)
        allow(BrApi::Assets::SyncJob).to receive(:perform_in).with(0.seconds,
                                                                   'MGLU3,VALE3,HAPV3,PETR4,B3SA3,BBDC4,SEQL3,ITSA4,ABEV3,PETZ3,TASA4').and_return(true)
        assets_global_sync_job
      end

      it 'updates the asset prices' do
        expect(HgBrasil::Assets::SyncJob).to have_received(:perform_in).exactly(3).times
        expect(BrApi::Assets::SyncJob).to have_received(:perform_in).once
        expect(btci11_hg_brasil_asset_price.reload).to be_scheduled
        expect(hglg11_hg_brasil_asset_price.reload).to be_processing

        [
          mgl3_hg_brasil_asset_price,
          vale3_hg_brasil_asset_price,
          hapv3_hg_brasil_asset_price,
          petr4_hg_brasil_asset_price,
          b3sa3_hg_brasil_asset_price,
          bbdc4_hg_brasil_asset_price,
          seql3_hg_brasil_asset_price,
          itsa4_hg_brasil_asset_price,
          abev3_hg_brasil_asset_price,
          petz3_hg_brasil_asset_price,
          tasa4_hg_brasil_asset_price
        ].each do |asset_price|
          expect(asset_price.reload).to be_scheduled
          expect(asset_price.scheduled_at).to be_a(Time)
        end

        [
          mgl3_br_api_asset_price,
          vale3_br_api_asset_price,
          hapv3_br_api_asset_price,
          petr4_br_api_asset_price,
          b3sa3_br_api_asset_price,
          bbdc4_br_api_asset_price,
          seql3_br_api_asset_price,
          itsa4_br_api_asset_price,
          abev3_br_api_asset_price,
          petz3_br_api_asset_price,
          tasa4_br_api_asset_price,
        ].each do |asset_price|
          expect(asset_price.reload).to be_scheduled
          expect(asset_price.scheduled_at).to be_a(Time)
        end
      end
    end

    context 'when there are rebalance orders being processed' do
      before do
        allow(HgBrasil::Assets::SyncJob).to receive(:perform_async).and_call_original
        allow(BrApi::Assets::SyncJob).to receive(:perform_async).and_call_original
        create(:rebalance_order, :default, :processing)
      end

      it 'does not update the asset prices' do
        response = assets_global_sync_job

        expect(response).to be_nil
        expect(HgBrasil::Assets::SyncJob).not_to have_received(:perform_async)
        expect(BrApi::Assets::SyncJob).not_to have_received(:perform_async)
      end
    end
  end
end
