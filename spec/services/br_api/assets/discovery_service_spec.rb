# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrApi::Assets::DiscoveryService do
  subject(:br_api_asset_discovery) { described_class.call(ticker_symbol:) }

  let!(:br_api_quotation_partner_resource) { create(:partner_resource, :br_api_quotation) }
  let!(:brl_currency) { create(:currency, :brl) }

  context 'when the asset does not exist' do
    context 'when ticker_symbol exists' do
      context 'when ticker_symbol is a stock' do
        let(:ticker_symbol) { 'PETR4' }

        it 'creates a new Asset and AssetPrice' do
          VCR.use_cassette('br_api_quotation/asset_discovery_success') do
            new_asset = br_api_asset_discovery

            expect(new_asset).to be_a(Asset)
            expect(new_asset.ticker_symbol).to eq('PETR4')
            expect(new_asset.name).to eq('Petróleo Brasileiro S.A. - Petrobras')
            expect(new_asset.kind).to eq('stock')
            expect(new_asset.custom).to eq(false)

            asset_price = new_asset.asset_prices.first

            expect(new_asset.asset_prices.count).to eq(1)
            expect(asset_price).to be_a(AssetPrice)
            expect(asset_price.currency).to eq(brl_currency)
            expect(asset_price.partner_resource).to eq(br_api_quotation_partner_resource)
            expect(asset_price.price).to eq(35.93)
            expect(asset_price.last_sync_at).to be_a(Time)
            expect(asset_price.created_at).to be_a(Time)
            expect(asset_price.updated_at).to be_a(Time)
            expect(asset_price.reference_date).to be_a(Time)
            expect(Log.info.count).to eq(2)
          end
        end
      end

      context 'when ticker_symbol is a fii' do
        let(:ticker_symbol) { 'HGLG11' }

        it 'creates a new Asset and AssetPrice' do
          VCR.use_cassette('br_api_quotation/asset_discovery_fii_success') do
            new_asset = br_api_asset_discovery

            expect(new_asset).to be_a(Asset)
            expect(new_asset.ticker_symbol).to eq('HGLG11')
            expect(new_asset.name).to eq('Cshg Logistica - Fundo De Investimento Imobiliario')
            expect(new_asset.kind).to eq('fii')
            expect(new_asset.custom).to eq(false)

            asset_price = new_asset.asset_prices.first

            expect(new_asset.asset_prices.count).to eq(1)
            expect(asset_price).to be_a(AssetPrice)
            expect(asset_price.currency).to eq(brl_currency)
            expect(asset_price.partner_resource).to eq(br_api_quotation_partner_resource)
            expect(asset_price.price).to eq(158.3)
            expect(asset_price.last_sync_at).to be_a(Time)
            expect(asset_price.created_at).to be_a(Time)
            expect(asset_price.updated_at).to be_a(Time)
            expect(asset_price.reference_date).to be_a(Time)
            expect(Log.info.count).to eq(2)
          end
        end
      end

      context 'when ticker_symbol is a ETF' do
        let(:ticker_symbol) { 'BOVA11' }

        it 'creates a new Asset and AssetPrice' do
          VCR.use_cassette('br_api_quotation/asset_discovery_etf_success') do
            new_asset = br_api_asset_discovery

            expect(new_asset).to be_a(Asset)
            expect(new_asset.ticker_symbol).to eq('BOVA11')
            expect(new_asset.name).to eq('iShares Ibovespa Index Fund')
            expect(new_asset.kind).to eq('etf')
            expect(new_asset.custom).to eq(false)

            asset_price = new_asset.asset_prices.first

            expect(new_asset.asset_prices.count).to eq(1)
            expect(asset_price).to be_a(AssetPrice)
            expect(asset_price.currency).to eq(brl_currency)
            expect(asset_price.partner_resource).to eq(br_api_quotation_partner_resource)
            expect(asset_price.price).to eq(116.76)
            expect(asset_price.last_sync_at).to be_a(Time)
            expect(asset_price.created_at).to be_a(Time)
            expect(asset_price.updated_at).to be_a(Time)
            expect(asset_price.reference_date).to be_a(Time)
            expect(Log.info.count).to eq(2)
          end
        end
      end
    end

    context 'when ticker symbol does not exist' do
      let(:ticker_symbol) { 'INVALID' }

      it 'returns nil' do
        VCR.use_cassette('br_api_quotation/asset_discovery_not_found') do
          response = br_api_asset_discovery
          expect(response).to be_nil
          expect(Log.error.count).to eq(0)
        end
      end
    end

    context 'when request fails' do
      let(:ticker_symbol) { 'PETR4' }

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::TimeoutError)
      end

      it 'returns nil' do
        VCR.use_cassette('br_api_quotation/asset_discovery_error') do
          response = br_api_asset_discovery

          expect(response).to be_nil
          expect(Log.error.count).to eq(1)
        end
      end
    end
  end

  context 'when asset already exists on database' do
    context 'when ticker_symbol is a stock' do
      let(:petr4) { create(:asset, ticker_symbol: 'PETR4', kind: 'stock', name: 'Petrobrás', custom: false) }
      let(:ticker_symbol) { petr4.ticker_symbol }

      context 'when asset_price already exists' do
        let!(:petr4_existing_asset_price) do
          create(:asset_price, asset: petr4, partner_resource: br_api_quotation_partner_resource, price: 36.98, currency: brl_currency)
        end

        it 'does not create a new AssetPrice' do
          VCR.use_cassette('br_api_quotation/existing_asset_discovery_stock_asset_price_already_created') do
            br_api_asset_discovery

            existing_asset = Asset.find_by(ticker_symbol: 'PETR4')
            asset_price = existing_asset.asset_prices.first

            expect(existing_asset).to eq(petr4)
            expect(Asset.count).to eq(1)
            expect(existing_asset.asset_prices.count).to eq(1)
            expect(asset_price).to eq(petr4_existing_asset_price)
          end
        end
      end

      context 'when asset_price does not exist' do
        it 'creates a new AssetPrice for the br_api_quotation_partner_resource' do
          VCR.use_cassette('br_api_quotation/existing_asset_discovery_stock_success') do
            br_api_asset_discovery

            existing_asset = Asset.find_by(ticker_symbol: 'PETR4')
            asset_price = existing_asset.asset_prices.first

            expect(existing_asset).to eq(petr4)
            expect(Asset.count).to eq(1)
            expect(existing_asset.asset_prices.count).to eq(1)
            expect(asset_price).to be_a(AssetPrice)
            expect(asset_price.currency).to eq(brl_currency)
            expect(asset_price.partner_resource).to eq(br_api_quotation_partner_resource)
            expect(asset_price.price).to eq(36.98)
            expect(asset_price.last_sync_at).to be_a(Time)
            expect(asset_price.created_at).to be_a(Time)
            expect(asset_price.updated_at).to be_a(Time)
            expect(asset_price.reference_date).to be_a(Time)
            expect(Log.info.count).to eq(2)
          end
        end
      end
    end

    context 'when ticker_symbol is a fii' do
      let(:hglg11) { create(:asset, ticker_symbol: 'HGLG11', kind: 'fii', name: 'CSHG LOGÍSTICA FDO INV IMOB - FII', custom: false) }
      let(:ticker_symbol) { hglg11.ticker_symbol }

      context 'when asset_price already exists' do
        let!(:hglg11_existing_asset_price) do
          create(:asset_price, asset: hglg11, partner_resource: br_api_quotation_partner_resource, price: 158.8, currency: brl_currency)
        end

        it 'does not create a new AssetPrice' do
          VCR.use_cassette('br_api_quotation/existing_asset_discovery_fii_asset_price_already_created') do
            br_api_asset_discovery

            existing_asset = Asset.find_by(ticker_symbol: 'HGLG11')
            asset_price = existing_asset.asset_prices.first

            expect(existing_asset).to eq(hglg11)
            expect(Asset.count).to eq(1)
            expect(existing_asset.asset_prices.count).to eq(1)
            expect(asset_price).to eq(hglg11_existing_asset_price)
          end
        end
      end

      context 'when asset_price does not exist' do
        it 'creates a new AssetPrice for the br_api_quotation_partner_resource' do
          VCR.use_cassette('br_api_quotation/existing_asset_discovery_fii_success') do
            br_api_asset_discovery

            existing_asset = Asset.find_by(ticker_symbol: 'HGLG11')
            asset_price = existing_asset.asset_prices.first

            expect(existing_asset).to eq(hglg11)
            expect(Asset.count).to eq(1)
            expect(existing_asset.asset_prices.count).to eq(1)
            expect(asset_price).to be_a(AssetPrice)
            expect(asset_price.currency).to eq(brl_currency)
            expect(asset_price.partner_resource).to eq(br_api_quotation_partner_resource)
            expect(asset_price.price).to eq(158.8)
            expect(asset_price.last_sync_at).to be_a(Time)
            expect(asset_price.created_at).to be_a(Time)
            expect(asset_price.updated_at).to be_a(Time)
            expect(asset_price.reference_date).to be_a(Time)
            expect(Log.info.count).to eq(2)
          end
        end
      end
    end

    context 'when ticker_symbol is a ETF' do
      let(:ivvb11) do
        create(:asset, ticker_symbol: 'IVVB11', kind: 'etf', name: 'iShares S&P 500 FIC de Fundo de Indice IE', custom: false)
      end
      let(:ticker_symbol) { ivvb11.ticker_symbol }

      context 'when asset_price already exists' do
        let!(:ivvb11_existing_asset_price) do
          create(:asset_price, asset: ivvb11, partner_resource: br_api_quotation_partner_resource, price: 330.79, currency: brl_currency)
        end

        it 'does not create a new AssetPrice' do
          VCR.use_cassette('br_api_quotation/existing_asset_discovery_etf_asset_price_already_created') do
            br_api_asset_discovery

            existing_asset = Asset.find_by(ticker_symbol: 'IVVB11')
            asset_price = existing_asset.asset_prices.first

            expect(existing_asset).to eq(ivvb11)
            expect(Asset.count).to eq(1)
            expect(existing_asset.asset_prices.count).to eq(1)
            expect(asset_price).to eq(ivvb11_existing_asset_price)
          end
        end
      end

      context 'when asset_price does not exist' do
        it 'creates a new AssetPrice for the br_api_quotation_partner_resource' do
          VCR.use_cassette('br_api_quotation/existing_asset_discovery_etf_success') do
            br_api_asset_discovery

            existing_asset = Asset.find_by(ticker_symbol: 'IVVB11')
            asset_price = existing_asset.asset_prices.first

            expect(existing_asset).to eq(ivvb11)
            expect(Asset.count).to eq(1)
            expect(existing_asset.asset_prices.count).to eq(1)
            expect(asset_price).to be_a(AssetPrice)
            expect(asset_price.currency).to eq(brl_currency)
            expect(asset_price.partner_resource).to eq(br_api_quotation_partner_resource)
            expect(asset_price.price).to eq(330.79)
            expect(asset_price.last_sync_at).to be_a(Time)
            expect(asset_price.created_at).to be_a(Time)
            expect(asset_price.updated_at).to be_a(Time)
            expect(asset_price.reference_date).to be_a(Time)
            expect(Log.info.count).to eq(2)
          end
        end
      end
    end
  end

  context 'when ticker_symbols does not exist on database and in the API' do
    let(:ticker_symbol) { 'INVALID' }

    it 'returns nil' do
      VCR.use_cassette('br_api_quotation/existing_asset_discovery_not_found') do
        response = br_api_asset_discovery
        expect(response).to be_nil
        expect(Log.error.count).to eq(0)
      end
    end
  end
end
