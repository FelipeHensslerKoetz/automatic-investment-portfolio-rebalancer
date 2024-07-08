# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrApi::CurrencyParityExchangeRates::SyncService do
  subject(:service) { described_class.new(currency_from_code:, currency_to_code:) }

  let!(:brl_currency) { create(:currency, :brl) }
  let!(:usd_currency) { create(:currency, :usd) }
  let!(:currency_parity) { create(:currency_parity, currency_from: usd_currency, currency_to: brl_currency) }
  let!(:br_api_usd_to_brl_currency_parity_exchange_rate) do
    create(:currency_parity_exchange_rate, :scheduled, :with_br_api_currencies_partner_resource, currency_parity:)
  end

  before do
    travel_to '2024-07-05'
  end

  describe '#call' do
    context 'when the currency parity exists on API' do
      context 'when the api returns the currency parity exchange rate' do
        let(:currency_from_code) { usd_currency.code }
        let(:currency_to_code) { brl_currency.code }

        it 'updates the currency parity exchange rate' do
          VCR.use_cassette('br_api/currency_parity_exchange_rates/sync_service/success') do
            service.call

            expect(br_api_usd_to_brl_currency_parity_exchange_rate.reload).to be_updated
            expect(br_api_usd_to_brl_currency_parity_exchange_rate.reload.reference_date.to_date).to eq(Date.parse('2024-07-04'))
            expect(br_api_usd_to_brl_currency_parity_exchange_rate.reload.exchange_rate).to eq(5.4887)
            expect(br_api_usd_to_brl_currency_parity_exchange_rate.reload.last_sync_at.to_date).to eq(Date.parse('2024-07-05'))
          end
        end
      end

      context 'when the api return an error' do
        let(:currency_from_code) { usd_currency.code }
        let(:currency_to_code) { brl_currency.code }

        before do
          allow(Integrations::BrApi::Currencies).to receive(:currencies_details).and_raise(StandardError)
        end

        it 'does not update the currency parity exchange rate' do
          VCR.use_cassette('br_api/currency_parity_exchange_rates/sync_service/error') do
            service.call

            expect(br_api_usd_to_brl_currency_parity_exchange_rate.reload).to be_failed
            expect(Log.error.count).to eq(1)
          end
        end
      end
    end

    context 'when the currency parity exchange rate has invalid status' do
      let(:currency_from_code) { usd_currency.code }
      let(:currency_to_code) { brl_currency.code }

      before do
        br_api_usd_to_brl_currency_parity_exchange_rate.status = 'pending'
        br_api_usd_to_brl_currency_parity_exchange_rate.save(validate: false)
      end

      it 'does not update the currency parity exchange rate' do
        service.call

        expect(br_api_usd_to_brl_currency_parity_exchange_rate.reload).to be_pending
        expect(Log.error.count).to eq(1)
      end
    end
  end

  describe '.call' do
    subject(:call) { described_class.call(currency_from_code:, currency_to_code:) }

    context 'when the currency parity exists on API' do
      let(:currency_from_code) { usd_currency.code }
      let(:currency_to_code) { brl_currency.code }

      it 'updates the currency parity exchange rate' do
        VCR.use_cassette('br_api/currency_parity_exchange_rates/sync_service/success/.call') do
          call

          expect(br_api_usd_to_brl_currency_parity_exchange_rate.reload).to be_updated
          expect(br_api_usd_to_brl_currency_parity_exchange_rate.reload.reference_date.to_date).to eq(Date.parse('2024-07-04'))
          expect(br_api_usd_to_brl_currency_parity_exchange_rate.reload.exchange_rate).to eq(5.4887)
          expect(br_api_usd_to_brl_currency_parity_exchange_rate.reload.last_sync_at.to_date).to eq(Date.parse('2024-07-05'))
        end
      end
    end

    context 'when the currency parity does not exist on API' do
      let(:currency_from_code) { usd_currency.code }
      let(:currency_to_code) { brl_currency.code }

      before do
        allow(Integrations::BrApi::Currencies).to receive(:currencies_details).and_raise(StandardError)
      end

      it 'does not update the currency parity exchange rate' do
        VCR.use_cassette('br_api/currency_parity_exchange_rates/sync_service/error') do
          call

          expect(br_api_usd_to_brl_currency_parity_exchange_rate.reload).to be_failed
          expect(Log.error.count).to eq(1)
        end
      end
    end

    context 'when the currency parity exchange rate has invalid status' do
      let(:currency_from_code) { usd_currency.code }
      let(:currency_to_code) { brl_currency.code }

      before do
        br_api_usd_to_brl_currency_parity_exchange_rate.status = 'pending'
        br_api_usd_to_brl_currency_parity_exchange_rate.save(validate: false)
      end

      it 'does not update the currency parity exchange rate' do
        call

        expect(br_api_usd_to_brl_currency_parity_exchange_rate.reload).to be_pending
        expect(Log.error.count).to eq(1)
      end
    end
  end
end
