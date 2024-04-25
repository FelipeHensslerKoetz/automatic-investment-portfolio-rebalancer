# frozen_string_literal: true

require 'rails_helper'
require 'hg_brasil/stocks'

RSpec.describe HgBrasil::Stocks do
  describe '.asset_details' do
    subject(:asset_details) { described_class.asset_details(symbol:) }

    context 'when searching for a stock price' do
      context 'wih valid symbol' do
        let(:symbol) { 'PETR4' }

        it 'returns the stock price' do
          VCR.use_cassette('hg_brasil_stock_price/valid_symbol') do
            result = asset_details

            expect(result).to be_a(Hash)
            expect(result).to include(
              ticker_symbol: be_a(String),
              kind: be_a(String),
              name: be_a(String),
              price: be_a(Float),
              reference_date: be_a(Time)
            )
            expect(Log.count).to eq(1)
          end
        end
      end

      context 'with invalid symbol' do
        let(:symbol) { 'INVALID' }

        it 'returns an empty hash' do
          VCR.use_cassette('hg_brasil_stock_price/invalid_symbol') do
            result = asset_details

            expect(result).to be_nil
            expect(Log.count).to eq(1)
          end
        end
      end
    end

    context 'when searching for a mutual fund price' do
      context 'with valid symbol' do
        let(:symbol) { 'HGLG11' }

        it 'returns the mutual fund price' do
          VCR.use_cassette('hg_brasil_stock_price/valid_mutual_fund') do
            result = asset_details

            expect(result).to be_a(Hash)
            expect(result).to include(
              ticker_symbol: be_a(String),
              kind: be_a(String),
              name: be_a(String),
              price: be_a(Float),
              reference_date: be_a(Time)
            )
            expect(Log.count).to eq(1)
          end
        end
      end

      context 'with invalid symbol' do
        let(:symbol) { 'INVALID' }

        it 'returns an empty hash' do
          VCR.use_cassette('hg_brasil_stock_price/invalid_mutual_fund') do
            result = asset_details

            expect(result).to be_nil
            expect(Log.count).to eq(1)
          end
        end
      end
    end

    context 'when http request fails' do
      let(:symbol) { 'PETR4' }

      context 'when Faraday::TimeoutError is raised' do
        before do
          allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::TimeoutError)
        end

        it 'raises an AlphaVantage::TimeoutError' do
          expect(asset_details).to be_nil
          expect(Log.count).to eq(1)
        end
      end

      context 'when Faraday::ConnectionFailed is raised' do
        before do
          allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::ConnectionFailed)
        end

        it 'raises an AlphaVantage::ConnectionFailedError' do
          expect(asset_details).to be_nil
          expect(Log.count).to eq(1)
        end
      end

      context 'when Faraday::ClientError is raised' do
        before do
          allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::ClientError)
        end

        it 'raises an AlphaVantage::ClientError' do
          expect(asset_details).to be_nil
          expect(Log.count).to eq(1)
        end
      end

      context 'when Faraday::ServerError is raised' do
        before do
          allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::ServerError)
        end

        it 'raises an AlphaVantage::ServerError' do
          expect(asset_details).to be_nil
          expect(Log.count).to eq(1)
        end
      end
    end
  end

  describe '.asset_details_batch' do
    subject(:asset_details_batch) { described_class.asset_details_batch(symbols:) }

    context 'when searching for up to 5' do
      context 'when all stocks are valid' do
        let(:symbols) { 'EMBR3,HGLG11,ITSA4,PETR4,VALE3' }

        it 'returns the stock prices' do
          VCR.use_cassette('hg_brasil_stock_price_batch/valid_symbols') do
            result = asset_details_batch

            expect(result).to be_an(Array)
            expect(result.size).to eq(5)

            result.each do |stock|
              expect(stock).to include(
                ticker_symbol: be_a(String),
                kind: be_a(String),
                name: be_a(String),
                price: be_a(Float),
                reference_date: be_a(Time)
              )
            end
          end
        end
      end

      context 'when some stocks are invalid' do
        let(:symbols) { 'FELIPE,HGLG11,INVALID,PETR4,VALE3' }

        it 'returns the stock prices' do
          VCR.use_cassette('hg_brasil_stock_price_batch/partial_invalid_symbols') do
            result = asset_details_batch

            expect(result).to be_an(Array)
            expect(result.size).to eq(3)

            result.each do |stock|
              expect(stock).to include(
                ticker_symbol: be_a(String),
                kind: be_a(String),
                name: be_a(String),
                price: be_a(Float),
                reference_date: be_a(Time)
              )
            end
          end
        end
      end

      context 'when all stocks are invalid' do
        let(:symbols) { 'INVALID,INVALID2,INVALID3,INVALID4' }

        it 'returns an empty array' do
          VCR.use_cassette('hg_brasil_stock_price_batch/all_invalid_symbols') do
            result = asset_details_batch

            expect(result).to eq([])
          end
        end
      end
    end

    context 'when searching for more than 5 stocks' do
      let(:symbols) { 'EMBR3,HGLG11,ITSA4,PETR4,VALE3,B3SA3' }

      it 'returns an empty array' do
        VCR.use_cassette('hg_brasil_stock_price_batch/more_than_5_symbols') do
          result = asset_details_batch

          expect(result).to be_nil
        end
      end
    end
  end
end
