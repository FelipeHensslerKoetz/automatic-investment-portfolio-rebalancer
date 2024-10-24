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
    it { should validate_presence_of(:rebalance_order_kind) }
    it { should validate_inclusion_of(:rebalance_order_kind).in_array(AutomaticRebalanceOption::REBALANCE_ORDER_KINDS) }

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

    context 'when validating amount' do 
      context 'when rebalance_order_kind is default' do
        context 'when amount is nil' do
          let(:automatic_rebalance_option) { create(:automatic_rebalance_option, amount: nil) }
  
          it 'sets default amount' do
            expect(automatic_rebalance_option).to be_valid
            expect(automatic_rebalance_option.amount).to eq(0)
          end
        end
  
        context 'when amount is not nil' do
          let(:automatic_rebalance_option) { create(:automatic_rebalance_option, amount: 100) }
  
          it 'does not set default amount' do
            expect(automatic_rebalance_option).to be_valid
            expect(automatic_rebalance_option.amount).to eq(100)
          end
        end
      end

      context 'when rebalance_order_kind is contribution' do
        context 'when amount is nil' do 
          let(:automatic_rebalance_option) { build(:automatic_rebalance_option, :contribution, amount: nil) }

          it 'does not set default amount' do
            expect(automatic_rebalance_option).not_to be_valid
            expect(automatic_rebalance_option.errors[:amount]).to include('is not a number')
          end

          it { expect { automatic_rebalance_option.save! }.to raise_error(ActiveRecord::RecordInvalid) }
        end

        context 'when amount is not nil' do
          context 'when amount is negative' do
            let(:automatic_rebalance_option) { build(:automatic_rebalance_option, :contribution, amount: -10) }

            it 'does not set default amount' do
              expect(automatic_rebalance_option).not_to be_valid
              expect(automatic_rebalance_option.errors[:amount]).to include('must be greater than 0')
            end
  
            it { expect { automatic_rebalance_option.save! }.to raise_error(ActiveRecord::RecordInvalid) }
          end

          context 'when amount is zero' do
            let(:automatic_rebalance_option) { build(:automatic_rebalance_option, :contribution, amount: 0) }

            it 'does not set default amount' do
              expect(automatic_rebalance_option).not_to be_valid
              expect(automatic_rebalance_option.errors[:amount]).to include('must be greater than 0')
            end
  
            it { expect { automatic_rebalance_option.save! }.to raise_error(ActiveRecord::RecordInvalid) }
          end

          context 'when amount is positive' do
            let(:automatic_rebalance_option) { create(:automatic_rebalance_option, :contribution, amount: 100) }

            it 'does not set default amount' do
              expect(automatic_rebalance_option).to be_valid
              expect(automatic_rebalance_option.amount).to eq(100)
            end
          end
        end
      end
    end
  end

  describe 'scopes' do
    let!(:variation_automatic_rebalance_option) { create(:automatic_rebalance_option, :variation) }
    let!(:recurrence_automatic_rebalance_option) { create(:automatic_rebalance_option, :recurrence) }

    describe '.variation' do
      it 'returns automatic rebalance options with kind variation' do
        expect(described_class.variation).to match_array([variation_automatic_rebalance_option])
      end
    end

    describe '.recurrence' do
      it 'returns automatic rebalance options with kind recurrence' do
        expect(described_class.recurrence).to match_array([recurrence_automatic_rebalance_option])
      end
    end
  end
end
