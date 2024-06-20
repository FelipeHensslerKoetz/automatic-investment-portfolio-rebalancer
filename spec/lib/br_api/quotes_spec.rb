# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrApi::Quotes do
  describe '.asset_details' do
    subject(:asset_details) { described_class.asset_details(ticker_symbols:) }

    context 'when searching one asset' do
      context 'when the ticker symbol is valid' do
        let(:ticker_symbols) { 'PETR4' }

        it 'returns the asset details' do
          VCR.use_cassette('br_api_asset_details/valid_ticker_symbol') do
            result = asset_details

            expect(result).to be_an(Array)
            expect(result.size).to eq(1)

            expect(result.first).to include(
              ticker_symbol: 'PETR4',
              kind: 'stock',
              name: 'Petróleo Brasileiro S.A. - Petrobras',
              price: 35.93,
              currency: 'BRL',
              reference_date: '2024-06-19T20:08:10.000Z'
            )
          end
        end
      end

      context 'when the ticker symbol is invalid' do
        let(:ticker_symbols) { 'INVALID' }

        it 'returns nil' do
          VCR.use_cassette('br_api_asset_details/invalid_ticker_symbol') do
            result = asset_details

            expect(result).to eq([])
          end
        end
      end
    end

    context 'when searching for up to 20 assets' do
      context 'when all ticker symbols are valid' do
        let(:ticker_symbols) { 'PETR4,VALE3,BBAS3' }

        it 'returns the asset details' do
          VCR.use_cassette('br_api_asset_details/valid_ticker_symbols') do
            result = asset_details

            expect(result).to be_an(Array)
            expect(result.size).to eq(3)
            expect(result).to contain_exactly(
              {
                ticker_symbol: 'PETR4',
                kind: 'stock',
                name: 'Petróleo Brasileiro S.A. - Petrobras',
                price: 35.93,
                currency: 'BRL',
                reference_date: '2024-06-19T20:08:10.000Z'
              },
              {
                ticker_symbol: 'VALE3',
                kind: 'stock',
                name: 'Vale S.A.',
                price: 60.85,
                currency: 'BRL',
                reference_date: '2024-06-19T20:07:53.000Z'
              },
              {
                ticker_symbol: 'BBAS3',
                kind: 'stock',
                name: 'Banco do Brasil S.A.',
                price: 26.27,
                currency: 'BRL',
                reference_date: '2024-06-19T20:07:52.000Z'
              }
            )
          end
        end
      end

      context 'when some ticker symbols are invalid' do
        let(:ticker_symbols) { 'PETR4,INVALID,BBAS3' }

        it 'returns only the valid assets details' do
          VCR.use_cassette('br_api_asset_details/some_invalid_ticker_symbols') do
            result = asset_details

            expect(result).to be_an(Array)
            expect(result.size).to eq(2)
            expect(result).to contain_exactly(
              {
                ticker_symbol: 'PETR4',
                kind: 'stock',
                name: 'Petróleo Brasileiro S.A. - Petrobras',
                price: 35.93,
                currency: 'BRL',
                reference_date: '2024-06-19T20:08:10.000Z'
              },
              {
                ticker_symbol: 'BBAS3',
                kind: 'stock',
                name: 'Banco do Brasil S.A.',
                price: 26.27,
                currency: 'BRL',
                reference_date: '2024-06-19T20:07:52.000Z'
              }
            )
          end
        end
      end

      context 'when all ticker symbols are invalid' do
        let(:ticker_symbols) { 'INVALID1,INVALID2,INVALID3' }

        it 'returns nil' do
          VCR.use_cassette('br_api_asset_details/all_invalid_ticker_symbols') do
            result = asset_details

            expect(result).to eq([])
          end
        end
      end
    end
  end
end
