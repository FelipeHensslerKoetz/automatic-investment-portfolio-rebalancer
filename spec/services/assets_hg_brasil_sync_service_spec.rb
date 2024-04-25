# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssetsHgBrasilSyncService, type: :service do
  subject(:sync_service) { described_class.new(asset_ticker_symbols:) }

  let!(:petr4) { create(:asset, ticker_symbol: 'PETR4') }
  let!(:wizc3) { create(:asset, ticker_symbol: 'WIZC3') }
  let!(:partner_resource) { create(:partner_resource, :hg_brasil_stock_price) }
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

  let(:asset_ticker_symbols) { "#{petr4.ticker_symbol},#{wizc3.ticker_symbol}" }

  describe '#call' do
    context 'when batch update is successful' do
      let(:hg_brasil_response) do
        [
          {
            ticker_symbol: 'PETR4',
            kind: 'stock',
            business_name: 'Petróleo Brasileiro S.A. - Petrobras',
            name: 'Petróleo Brasileiro S.A. - Petrobras',
            price: 25.0,
            reference_date: Time.zone.parse('2023-04-17'),
            currency: 'BRL',
            custom: false
          },
          {
            ticker_symbol: 'WIZC3',
            kind: 'stock',
            business_name: 'Wiz Soluções e Corretagem de Seguros S.A.',
            name: 'Wiz Soluções e Corretagem de Seguros S.A.',
            price: 5.0,
            reference_date: Time.zone.parse('2023-04-17'),
            currency: 'BRL',
            custom: false
          }
        ]
      end

      before do
        allow(HgBrasil::Stocks).to receive(:asset_details_batch).with(asset_ticker_symbols:).and_return(hg_brasil_response)
        sync_service.call
      end

      it 'updates assets to success status' do
        expect(petr4_price.reload.status).to eq('updated')
        expect(petr4_price.reload.price).to eq(hg_brasil_response[0][:price])
        expect(petr4_price.reference_date).to eq(hg_brasil_response[0][:reference_date])
        expect(wizc3_price.reload.status).to eq('updated')
        expect(wizc3_price.reload.price).to eq(hg_brasil_response[1][:price])
        expect(wizc3_price.reference_date).to eq(hg_brasil_response[1][:reference_date])
        expect(HgBrasil::Stocks).to have_received(:asset_details_batch).with(asset_ticker_symbols:).once
      end
    end

    context 'when batch update fails' do
      before do
        allow(HgBrasil::Stocks).to receive(:asset_details_batch).with(asset_ticker_symbols:).and_raise(StandardError)
        sync_service.call
      end

      it 'update assets to failed status' do
        expect(petr4_price.reload.status).to eq('failed')
        expect(wizc3_price.reload.status).to eq('failed')
      end
    end
  end
end
