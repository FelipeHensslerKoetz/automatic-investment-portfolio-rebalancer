# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrencyParity, type: :model do
  describe 'associations' do
    it { should belong_to(:currency_from).class_name('Currency') }
    it { should belong_to(:currency_to).class_name('Currency') }
    it { should have_many(:currency_parity_exchange_rates).dependent(:restrict_with_error) }
  end

  describe 'methods' do
    describe '#newest_currency_parity_exchange_rate_by_reference_date' do
      context 'when there are no currency parity exchange rates' do
        it 'returns nil' do
          currency_parity = create(:currency_parity)

          expect(currency_parity.newest_currency_parity_exchange_rate_by_reference_date).to be_nil
        end
      end

      context 'when there are currency parity exchange rates' do
        it 'returns the newest currency parity exchange rate by reference date' do
          currency_parity = create(:currency_parity)
          create(:currency_parity_exchange_rate,
                 :with_hg_brasil_stock_price_partner_resource,
                 currency_parity:,
                 reference_date: 1.day.ago)
          newest_currency_parity_exchange_rate = create(:currency_parity_exchange_rate, :with_hg_brasil_stock_price_partner_resource,
                                                        currency_parity:,
                                                        reference_date: Time.zone.today)

          expect(currency_parity.newest_currency_parity_exchange_rate_by_reference_date).to eq(newest_currency_parity_exchange_rate)
        end
      end
    end
  end
end
