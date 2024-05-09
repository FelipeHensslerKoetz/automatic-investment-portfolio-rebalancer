# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Currency, type: :model do
  describe 'associations' do
    it {
      is_expected.to have_many(:currency_parities_as_from)
        .class_name('CurrencyParity')
        .with_foreign_key('from_currency_id')
        .inverse_of(:currency_from)
        .dependent(:restrict_with_error)
    }

    it {
      is_expected.to have_many(:currency_parities_as_to)
        .class_name('CurrencyParity')
        .with_foreign_key('to_currency_id')
        .inverse_of(:currency_to)
        .dependent(:restrict_with_error)
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:code) }

    it 'validates uniqueness of code' do
      create(:currency, :usd)
      expect(build(:currency, code: 'USD')).to validate_uniqueness_of(:code)
    end
  end

  describe 'class methods' do
    describe '.find' do
      it 'finds by id' do
        currency = create(:currency, :usd)
        expect(described_class.find(currency.id)).to eq(currency)
      end

      it 'finds by code' do
        currency = create(:currency, :usd)
        expect(described_class.find(currency.code)).to eq(currency)
      end

      it 'raises an error if not found' do
        expect { described_class.find('USD') }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
