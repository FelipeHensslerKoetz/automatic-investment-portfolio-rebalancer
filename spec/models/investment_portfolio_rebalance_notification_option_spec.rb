require 'rails_helper'

RSpec.describe InvestmentPortfolioRebalanceNotificationOption, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:investment_portfolio) }
    it { is_expected.to have_many(:investment_portfolio_rebalance_notification_orders).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_inclusion_of(:kind).in_array(InvestmentPortfolioRebalanceNotificationOption::NOTIFICATION_OPTION_KINDS) }

    context 'when kind is webhook' do
      let(:webhook_notification_option) { build(:investment_portfolio_rebalance_notification_option, :webhook) }

      context 'when url is not present' do
        it 'is invalid' do
          webhook_notification_option.url = nil
          expect(webhook_notification_option).to be_invalid
          expect(webhook_notification_option.errors[:url]).to include("can't be blank")
        end
      end

      context 'when header is invalid' do
        it 'is invalid' do
          webhook_notification_option.header = 'abc'
          expect(webhook_notification_option).to be_invalid
          expect(webhook_notification_option.errors[:header]).to include("must be an object")
        end
      end

      context 'when header is not a hash' do
        it 'is invalid' do
          webhook_notification_option.header = 'invalid'
          expect(webhook_notification_option).to be_invalid
          expect(webhook_notification_option.errors[:header]).to include("must be an object")
        end
      end

      context 'when all attributes are valid' do
        it 'is valid' do
          expect(webhook_notification_option).to be_valid
        end
      end
    end
  end
end
