# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Integrations::HgBrasil::Currencies do
  subject(:quotes) { described_class.quote_details }

  context 'when request is successful' do
    it 'return the quote details' do
      VCR.use_cassette('hg_brasil_quotes/success') do
        result = quotes

        expect(result).to be_a(Hash)
        expect(result['results']).to be_a(Hash)
        expect(result['results'].keys).to contain_exactly('currencies', 'stocks', 'available_sources', 'bitcoin')
        expect(result['results']['currencies'].keys).to contain_exactly('ARS', 'AUD', 'BTC', 'CAD', 'CNY',
                                                                        'EUR', 'GBP', 'JPY', 'USD', 'source')
        result['results']['currencies'].each do |key, value|
          next if key == 'source'

          expect(value).to be_a(Hash)
          expect(value.keys).to contain_exactly('name', 'buy', 'sell', 'variation')
          expect(value['name']).to be_a(String)
          expect(value['buy']).to be_a(Float)
          expect(value['variation']).to be_a(Float)
        end
      end
    end
  end

  context 'when request is not successful' do
    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::TimeoutError)
    end

    it 'raises an error' do
      VCR.use_cassette('hg_brasil_quotes/error') do
        result = quotes

        expect(result).to be_nil
      end
    end
  end
end
