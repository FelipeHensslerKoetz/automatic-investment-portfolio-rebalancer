# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrencyParityExchangeRate, type: :model do
  describe 'associations' do
    it { should belong_to(:currency_parity) }
    it { should belong_to(:partner_resource) }
  end

  describe 'validations' do
    it { should validate_presence_of(:exchange_rate) }
    it { should validate_presence_of(:reference_date) }
    it { should validate_presence_of(:last_sync_at) }
  end

  describe 'scopes' do
    let!(:updated_currency_parity_exchange_rate) do
      create(:currency_parity_exchange_rate, :updated, :with_hg_brasil_stock_price_partner_resource)
    end
    let!(:processing_currency_parity_exchange_rate) do
      create(:currency_parity_exchange_rate, :processing, :with_hg_brasil_stock_price_partner_resource)
    end
    let!(:failed_currency_parity_exchange_rate) do
      create(:currency_parity_exchange_rate, :failed, :with_hg_brasil_stock_price_partner_resource)
    end
    let!(:scheduled_currency_parity_exchange_rate) do
      create(:currency_parity_exchange_rate, :scheduled, :with_hg_brasil_stock_price_partner_resource)
    end

    describe '.updated' do
      it 'returns up to date currency parity exchange rate' do
        expect(CurrencyParityExchangeRate.updated).to contain_exactly(updated_currency_parity_exchange_rate)
      end
    end

    describe '.processing' do
      it 'returns processing currency parity exchange rate' do
        expect(CurrencyParityExchangeRate.processing).to contain_exactly(processing_currency_parity_exchange_rate)
      end
    end

    describe '.failed' do
      it 'returns failed currency parity exchange rate' do
        expect(CurrencyParityExchangeRate.failed).to contain_exactly(failed_currency_parity_exchange_rate)
      end
    end

    describe '.scheduled' do
      it 'returns scheduled currency parity exchange rate' do
        expect(CurrencyParityExchangeRate.scheduled).to contain_exactly(scheduled_currency_parity_exchange_rate)
      end
    end
  end

  describe 'aasm' do
    it { should have_state(:updated) }
    it { should transition_from(:updated).to(:scheduled).on_event(:schedule) }
    it { should transition_from(:failed).to(:scheduled).on_event(:schedule) }
    it { should transition_from(:scheduled).to(:processing).on_event(:process) }
    it { should transition_from(:processing).to(:failed).on_event(:fail) }
    it { should transition_from(:processing).to(:updated).on_event(:up_to_date) }
  end
end
