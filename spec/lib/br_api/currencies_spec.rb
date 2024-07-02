# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrApi::Currencies do
  describe '.currencies_details' do
    subject(:currencies_details) { described_class.currencies_details(from_to_iso_code:) }

    context 'when iso codes is valid' do
      let(:from_to_iso_code) do
        [
          'USD-BRL'
        ].join(',')
      end

      it 'return the currencies details' do
        VCR.use_cassette('br_api_currencies/success') do
          result = currencies_details

          expect(result).to eq([
                                 {
                                   currency_from_code: 'USD',
                                   currency_to_code: 'BRL',
                                   exchange_rate: '5.6563',
                                   reference_date: '2024-07-01 18:06:30'
                                 }
                               ])
        end
      end
    end

    context 'when iso code is invalid' do
      let(:from_to_iso_code) do
        [
          '???-BRL'
        ].join(',')
      end

      it 'return nil' do
        VCR.use_cassette('br_api_currencies/invalid') do
          result = currencies_details

          expect(result).to be_nil
        end
      end
    end

    context 'when an error occurs' do
      let(:from_to_iso_code) do
        [
          'USD-BRL'
        ].join(',')
      end

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::TimeoutError)
      end

      it 'return nil' do
        VCR.use_cassette('br_api_currencies/error') do
          result = currencies_details

          expect(result).to be_nil
        end
      end
    end
  end
end
