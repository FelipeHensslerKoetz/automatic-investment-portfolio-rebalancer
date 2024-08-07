# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AutomaticRebalanceOption, type: :model do
  describe 'associations' do
    it { should belong_to(:investment_portfolio) }
  end

  describe 'validations' do
    it { should validate_inclusion_of(:kind).in_array(AutomaticRebalanceOption::AUTOMATIC_REBALANCE_OPTIONS) }
    it { should validate_presence_of(:kind) }
    it { should validate_presence_of(:start_date) }

    context 'when kind is recurrence' do
      subject { described_class.new(kind: 'recurrence') }

      it { should validate_numericality_of(:recurrence_days).only_integer.is_greater_than(0) }
    end

    context 'investment_portfolio_id uniqueness' do
      let!(:investment_portfolio) { create(:investment_portfolio) }
      let!(:automatic_rebalance_option) { create(:automatic_rebalance_option, investment_portfolio:) }

      it 'validates uniqueness of investment_portfolio_id' do
        new_automatic_rebalance_option = build(:automatic_rebalance_option, investment_portfolio:)

        expect(new_automatic_rebalance_option).not_to be_valid
        expect(new_automatic_rebalance_option.errors[:investment_portfolio_id]).to include('has already been taken')
      end
    end
  end
end
