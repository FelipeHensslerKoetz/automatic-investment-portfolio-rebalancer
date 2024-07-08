# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HgBrasil::Assets::SyncService, type: :service do
  subject(:sync_service) { described_class.new(ticker_symbols:) }

  let!(:petr4) { create(:asset, ticker_symbol: 'PETR4') }
  let!(:wizc3) { create(:asset, ticker_symbol: 'WIZC3') }
  let!(:partner_resource) { create(:partner_resource, :hg_brasil_assets) }
  let!(:petr4_price) do
    create(:asset_price,
           asset: petr4,
           ticker_symbol: 'PETR4',
           status: 'scheduled',
           partner_resource:)
  end

  let!(:wizc3_price) do
    create(:asset_price,
           asset: wizc3,
           ticker_symbol: 'WIZC3',
           status: 'scheduled',
           partner_resource:)
  end

  let(:ticker_symbols) { "#{petr4.ticker_symbol},#{wizc3.ticker_symbol}" }

  describe '#call' do
    context 'when batch update is successful' do
      before do
        allow(Integrations::HgBrasil::Assets).to receive(:asset_details).with(ticker_symbols:).and_call_original
      end

      it 'updates assets to success status' do
        VCR.use_cassette('hg_brasil/sync_service_success') do
          sync_service.call
          expect(petr4_price.reload.status).to eq('updated')
          expect(petr4_price.reload.price).to eq(38.05)
          expect(petr4_price.reference_date.to_date).to eq(Date.parse('2024-06-29'))
          expect(petr4_price.error_message).to be_nil

          expect(wizc3_price.reload.status).to eq('updated')
          expect(wizc3_price.reload.price).to eq(5.71)
          expect(wizc3_price.reference_date.to_date).to eq(Date.parse('2024-06-29'))
          expect(wizc3_price.error_message).to be_nil

          expect(Integrations::HgBrasil::Assets).to have_received(:asset_details).with(ticker_symbols:).once
          expect(Log.info.count).to eq(3)
        end
      end
    end

    context 'when batch update is partially successful' do
      let(:ticker_symbols) { "#{petr4.ticker_symbol},#{wizc3.ticker_symbol},#{unavailable_asset.ticker_symbol}" }
      let!(:unavailable_asset) { create(:asset, ticker_symbol: 'UNAVAILABLE_ASSET') }
      let!(:unavailable_asset_price) do
        create(:asset_price,
               asset: unavailable_asset,
               ticker_symbol: 'UNAVAILABLE_ASSET',
               status: 'scheduled',
               partner_resource:)
      end

      before do
        allow(Integrations::HgBrasil::Assets).to receive(:asset_details).with(ticker_symbols:).and_call_original
      end

      it 'updates available assets to success status and unavailable asset to failed status' do
        VCR.use_cassette('hg_brasil/sync_service_partially_success') do
          sync_service.call

          expect(petr4_price.reload.status).to eq('updated')
          expect(petr4_price.reload.price).to eq(38.05)
          expect(petr4_price.reference_date.to_date).to eq(Date.parse('2024-06-29'))
          expect(petr4_price.error_message).to be_nil

          expect(wizc3_price.reload.status).to eq('updated')
          expect(wizc3_price.reload.price).to eq(5.71)
          expect(wizc3_price.reference_date.to_date).to eq(Date.parse('2024-06-29'))
          expect(wizc3_price.error_message).to be_nil

          expect(unavailable_asset_price.reload.status).to eq('failed')
          expect(unavailable_asset_price.error_message).to be_present

          expect(Integrations::HgBrasil::Assets).to have_received(:asset_details).with(ticker_symbols:).once
          expect(Log.info.count).to eq(3)
          expect(Log.error.count).to eq(1)
        end
      end
    end

    context 'when batch update fails' do
      before do
        allow(Integrations::HgBrasil::Assets).to receive(:asset_details).with(ticker_symbols:).and_raise(StandardError, 'Error')
        sync_service.call
      end

      it 'update assets to failed status' do
        expect(petr4_price.reload.status).to eq('failed')
        expect(petr4_price.error_message).to eq('Error')

        expect(wizc3_price.reload.status).to eq('failed')
        expect(wizc3_price.error_message).to eq('Error')

        expect(Integrations::HgBrasil::Assets).to have_received(:asset_details).with(ticker_symbols:).twice
        expect(Log.error.count).to eq(2)
      end
    end
  end
end
