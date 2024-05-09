# frozen_string_literal: true

require 'rails_helper'
require 'hg_brasil/stocks'

RSpec.describe HgBrasil::Stocks do
  describe '.asset_details' do
    subject(:asset_details) { described_class.asset_details(ticker_symbols:) }

    context 'when searching one asset' do
      context 'when the stock is valid' do
        let(:ticker_symbols) { 'PETR4' }

        it 'returns the stock price' do
          VCR.use_cassette('hg_brasil_asset_details/valid_ticker_symbol') do
            result = asset_details

            expect(result).to be_an(Array)
            expect(result.size).to eq(1)

            expect(result.first).to include(
              ticker_symbol: 'PETR4',
              kind: be_a(String),
              name: be_a(String),
              price: be_a(Float),
              reference_date: be_a(Time),
              currency: be_a(String)
            )
          end
        end
      end

      context 'when the stock is invalid' do
        let(:ticker_symbols) { 'INVALID' }

        it 'returns an empty array' do
          VCR.use_cassette('hg_brasil_asset_details/invalid_ticker_symbol') do
            result = asset_details

            expect(result).to eq([])
          end
        end
      end
    end

    context 'when searching for up to 5' do
      context 'when all stocks are valid' do
        let(:ticker_symbols) { 'EMBR3,HGLG11,ITSA4,PETR4,VALE3' }

        it 'returns the stock prices' do
          VCR.use_cassette('hg_brasil_asset_details/valid_ticker_symbols') do
            result = asset_details

            expect(result).to be_an(Array)
            expect(result.size).to eq(5)

            result.each do |stock|
              expect(stock).to include(
                ticker_symbol: be_a(String),
                kind: be_a(String),
                name: be_a(String),
                price: be_a(Float),
                reference_date: be_a(Time),
                currency: be_a(String)
              )
            end
          end
        end
      end

      context 'when some stocks are invalid' do
        let(:ticker_symbols) { 'FELIPE,HGLG11,INVALID,PETR4,VALE3' }

        it 'returns the stock prices' do
          VCR.use_cassette('hg_brasil_asset_details/partial_invalid_ticker_symbols') do
            result = asset_details

            expect(result).to be_an(Array)
            expect(result.size).to eq(3)

            result.each do |stock|
              expect(stock).to include(
                ticker_symbol: be_a(String),
                kind: be_a(String),
                name: be_a(String),
                price: be_a(Float),
                reference_date: be_a(Time),
                currency: be_a(String)
              )
            end
          end
        end
      end

      context 'when all stocks are invalid' do
        let(:ticker_symbols) { 'INVALID,INVALID2,INVALID3,INVALID4' }

        it 'returns an empty array' do
          VCR.use_cassette('hg_brasil_asset_details/all_invalid_ticker_symbols') do
            result = asset_details

            expect(result).to eq([])
          end
        end
      end
    end

    context 'when searching for more than 5 stocks' do
      let(:ticker_symbols) { 'EMBR3,HGLG11,ITSA4,PETR4,VALE3,B3SA3' }

      it 'returns an empty array' do
        VCR.use_cassette('hg_brasil_asset_details/more_than_5_ticker_symbols') do
          result = asset_details

          expect(result).to be_nil
        end
      end
    end
  end
end
