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
    describe '.updated' do
      it 'returns up to date currency parity exchange rate' do
        updated_currency_parity_exchange_rate = create(:currency_parity_exchange_rate, :updated,
                                                       :with_hg_brasil_stock_price_partner_resource)
        create(:currency_parity_exchange_rate, :outdated, :with_hg_brasil_stock_price_partner_resource)
        expect(CurrencyParityExchangeRate.updated.count).to eq(1)
        expect(CurrencyParityExchangeRate.updated).to include(updated_currency_parity_exchange_rate)
      end
    end

    describe '.outdated' do
      it 'returns outdated currency parity exchange rate' do
        outdated_currency_parity_exchange_rate = create(:currency_parity_exchange_rate, :outdated,
                                                        :with_hg_brasil_stock_price_partner_resource)
        create(:currency_parity_exchange_rate, :updated, :with_hg_brasil_stock_price_partner_resource)
        expect(CurrencyParityExchangeRate.outdated.count).to eq(1)
        expect(CurrencyParityExchangeRate.outdated).to include(outdated_currency_parity_exchange_rate)
      end
    end

    describe '.processing' do
      it 'returns processing currency parity exchange rate' do
        processing_currency_parity_exchange_rate = create(:currency_parity_exchange_rate, :processing,
                                                          :with_hg_brasil_stock_price_partner_resource)
        create(:currency_parity_exchange_rate, :updated, :with_hg_brasil_stock_price_partner_resource)
        expect(CurrencyParityExchangeRate.processing.count).to eq(1)
        expect(CurrencyParityExchangeRate.processing).to include(processing_currency_parity_exchange_rate)
      end
    end

    describe '.failed' do
      it 'returns failed currency parity exchange rate' do
        failed_currency_parity_exchange_rate = create(:currency_parity_exchange_rate, :failed, :with_hg_brasil_stock_price_partner_resource)
        create(:currency_parity_exchange_rate, :updated, :with_hg_brasil_stock_price_partner_resource)
        expect(CurrencyParityExchangeRate.failed.count).to eq(1)
        expect(CurrencyParityExchangeRate.failed).to include(failed_currency_parity_exchange_rate)
      end
    end

    describe '.scheduled' do
      it 'returns scheduled currency parity exchange rate' do
        scheduled_currency_parity_exchange_rate = create(:currency_parity_exchange_rate, :scheduled,
                                                         :with_hg_brasil_stock_price_partner_resource)
        create(:currency_parity_exchange_rate, :updated, :with_hg_brasil_stock_price_partner_resource)
        expect(CurrencyParityExchangeRate.scheduled.count).to eq(1)
        expect(CurrencyParityExchangeRate.scheduled).to include(scheduled_currency_parity_exchange_rate)
      end
    end
  end

  describe 'aasm' do
    it { should have_state(:updated) }
    it { should transition_from(:outdated).to(:scheduled).on_event(:schedule) }
    it { should transition_from(:failed).to(:scheduled).on_event(:schedule) }
    it { should transition_from(:scheduled).to(:processing).on_event(:process) }
    it { should transition_from(:processing).to(:failed).on_event(:fail) }
    it { should transition_from(:processing).to(:updated).on_event(:up_to_date) }
    it { should transition_from(:updated).to(:outdated).on_event(:out_of_date) }
  end
end
