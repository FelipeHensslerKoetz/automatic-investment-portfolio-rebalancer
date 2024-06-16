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
  end
end
