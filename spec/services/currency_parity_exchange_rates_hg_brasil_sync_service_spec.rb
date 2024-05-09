# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrencyParityExchangeRatesHgBrasilSyncService do
  subject(:currency_parity_exchange_rates_hg_brasil_sync_service) { described_class.call }

  describe '.call' do
    context 'when request is successful' do
      let!(:usd_to_brl_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate,
               :scheduled,
               currency_parity: usd_to_brl_currency_parity,
               partner_resource: hg_brasil_partner_resource)
      end

      let!(:eur_to_brl_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate,
               :scheduled,
               currency_parity: eur_to_brl_currency_parity,
               partner_resource: hg_brasil_partner_resource)
      end

      let!(:gbp_to_brl_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate,
               :scheduled,
               currency_parity: gbp_to_brl_currency_parity,
               partner_resource: hg_brasil_partner_resource)
      end

      let!(:ars_to_brl_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate,
               :scheduled,
               currency_parity: ars_to_brl_currency_parity,
               partner_resource: hg_brasil_partner_resource)
      end

      let!(:cad_to_brl_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate,
               :scheduled,
               currency_parity: cad_to_brl_currency_parity,
               partner_resource: hg_brasil_partner_resource)
      end

      let!(:aud_to_brl_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate,
               :scheduled,
               currency_parity: aud_to_brl_currency_parity,
               partner_resource: hg_brasil_partner_resource)
      end

      let!(:jpy_to_brl_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate,
               :scheduled,
               currency_parity: jpy_to_brl_currency_parity,
               partner_resource: hg_brasil_partner_resource)
      end

      let!(:cny_to_brl_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate,
               :scheduled,
               currency_parity: cny_to_brl_currency_parity,
               partner_resource: hg_brasil_partner_resource)
      end

      let!(:btc_to_brl_currency_parity_exchange_rate) do
        create(:currency_parity_exchange_rate,
               :scheduled,
               currency_parity: btc_to_brl_currency_parity,
               partner_resource: hg_brasil_partner_resource)
      end

      let(:hg_brasil_partner_resource) { create(:partner_resource, :hg_brasil_quotation) }
      let(:brl_currency) { create(:currency, code: 'BRL', name: 'Brazilian Real') }
      let(:usd_currency) { create(:currency, code: 'USD', name: 'US Dollar') }
      let(:eur_currency) { create(:currency, code: 'EUR', name: 'Euro') }
      let(:gbp_currency) { create(:currency, code: 'GBP', name: 'British Pound') }
      let(:ars_currency) { create(:currency, code: 'ARS', name: 'Argentine Peso') }
      let(:cad_currency) { create(:currency, code: 'CAD', name: 'Canadian Dollar') }
      let(:aud_currency) { create(:currency, code: 'AUD', name: 'Australian Dollar') }
      let(:jpy_currency) { create(:currency, code: 'JPY', name: 'Japanese Yen') }
      let(:cny_currency) { create(:currency, code: 'CNY', name: 'Chinese Yuan') }
      let(:btc_currency) { create(:currency, code: 'BTC', name: 'Bitcoin') }
      let(:usd_to_brl_currency_parity) { create(:currency_parity, currency_from: usd_currency, currency_to: brl_currency) }
      let(:eur_to_brl_currency_parity) { create(:currency_parity, currency_from: eur_currency, currency_to: brl_currency) }
      let(:gbp_to_brl_currency_parity) { create(:currency_parity, currency_from: gbp_currency, currency_to: brl_currency) }
      let(:ars_to_brl_currency_parity) { create(:currency_parity, currency_from: ars_currency, currency_to: brl_currency) }
      let(:cad_to_brl_currency_parity) { create(:currency_parity, currency_from: cad_currency, currency_to: brl_currency) }
      let(:aud_to_brl_currency_parity) { create(:currency_parity, currency_from: aud_currency, currency_to: brl_currency) }
      let(:jpy_to_brl_currency_parity) { create(:currency_parity, currency_from: jpy_currency, currency_to: brl_currency) }
      let(:cny_to_brl_currency_parity) { create(:currency_parity, currency_from: cny_currency, currency_to: brl_currency) }
      let(:btc_to_brl_currency_parity) { create(:currency_parity, currency_from: btc_currency, currency_to: brl_currency) }

      it 'updates the currency parity exchange rates' do
        VCR.use_cassette('currency_parity_exchange_rates_hg_brasil_sync_service/success') do
          currency_parity_exchange_rates_hg_brasil_sync_service

          expect(usd_to_brl_currency_parity_exchange_rate.reload.exchange_rate).to eq(5.0889.to_d)
          expect(usd_to_brl_currency_parity_exchange_rate).to be_updated

          expect(eur_to_brl_currency_parity_exchange_rate.reload.exchange_rate).to eq(5.4704.to_d)
          expect(eur_to_brl_currency_parity_exchange_rate).to be_updated

          expect(gbp_to_brl_currency_parity_exchange_rate.reload.exchange_rate).to eq(6.3599.to_d)
          expect(gbp_to_brl_currency_parity_exchange_rate).to be_updated

          expect(ars_to_brl_currency_parity_exchange_rate.reload.exchange_rate).to eq(0.0058.to_d)
          expect(ars_to_brl_currency_parity_exchange_rate).to be_updated

          expect(cad_to_brl_currency_parity_exchange_rate.reload.exchange_rate).to eq(3.7078.to_d)
          expect(cad_to_brl_currency_parity_exchange_rate).to be_updated

          expect(aud_to_brl_currency_parity_exchange_rate.reload.exchange_rate).to eq(3.3484.to_d)
          expect(aud_to_brl_currency_parity_exchange_rate).to be_updated

          expect(jpy_to_brl_currency_parity_exchange_rate.reload.exchange_rate).to eq(0.0327.to_d)
          expect(jpy_to_brl_currency_parity_exchange_rate).to be_updated

          expect(cny_to_brl_currency_parity_exchange_rate.reload.exchange_rate).to eq(0.7044.to_d)
          expect(cny_to_brl_currency_parity_exchange_rate).to be_updated

          expect(btc_to_brl_currency_parity_exchange_rate.reload.exchange_rate).to eq(329_770.184.to_d)
          expect(btc_to_brl_currency_parity_exchange_rate).to be_updated
        end
      end
    end

    context 'when request is not successful' do
      it 'saves a log error' do
        VCR.use_cassette('currency_parity_exchange_rates_hg_brasil_sync_service/failure') do
          currency_parity_exchange_rates_hg_brasil_sync_service

          expect(Log.error.count).to eq(1)
        end
      end
    end
  end
end
