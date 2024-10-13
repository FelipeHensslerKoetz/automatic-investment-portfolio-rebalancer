require 'rails_helper'

RSpec.describe InvestmentPortfolioRebalanceNotificationOrder, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:investment_portfolio) }
    it { is_expected.to belong_to(:investment_portfolio_rebalance_notification_option) }
    it { is_expected.to belong_to(:rebalance) }
    it { is_expected.to belong_to(:rebalance_order) }
  end

  describe 'aasm' do
    

    describe 'pending state' do 
      let(:investment_portfolio_rebalance_notification_order) { create(:investment_portfolio_rebalance_notification_order, :pending) } 

      it { expect(investment_portfolio_rebalance_notification_order).to be_pending }
      it { expect { investment_portfolio_rebalance_notification_order.process! }.not_to raise_error }
      it { expect { investment_portfolio_rebalance_notification_order.error! }.to raise_error(AASM::InvalidTransition) }
      it { expect { investment_portfolio_rebalance_notification_order.success! }.to raise_error(AASM::InvalidTransition) }
      it { expect { investment_portfolio_rebalance_notification_order.reprocess! }.to raise_error(AASM::InvalidTransition) }
      it { expect { investment_portfolio_rebalance_notification_order.process! }.to change { investment_portfolio_rebalance_notification_order.status }.from('pending').to('processing') }
    end

    describe 'processing state' do 
      let(:investment_portfolio_rebalance_notification_order) { create(:investment_portfolio_rebalance_notification_order, :processing) } 

      it { expect(investment_portfolio_rebalance_notification_order).to be_processing }
      it { expect { investment_portfolio_rebalance_notification_order.process! }.to raise_error(AASM::InvalidTransition) }
      it { expect { investment_portfolio_rebalance_notification_order.error! }.not_to raise_error }
      it { expect { investment_portfolio_rebalance_notification_order.success! }.not_to raise_error }
      it { expect { investment_portfolio_rebalance_notification_order.reprocess! }.to raise_error(AASM::InvalidTransition) }
      it { expect { investment_portfolio_rebalance_notification_order.success! }.to change { investment_portfolio_rebalance_notification_order.status }.from('processing').to('success') }
      it { expect { investment_portfolio_rebalance_notification_order.error! }.to change { investment_portfolio_rebalance_notification_order.status }.from('processing').to('error') }
    end

    describe 'success state' do
      let(:investment_portfolio_rebalance_notification_order) { create(:investment_portfolio_rebalance_notification_order, :success) }

      it { expect(investment_portfolio_rebalance_notification_order).to be_success }
      it { expect { investment_portfolio_rebalance_notification_order.process! }.to raise_error(AASM::InvalidTransition) }
      it { expect { investment_portfolio_rebalance_notification_order.error! }.to raise_error(AASM::InvalidTransition) }
      it { expect { investment_portfolio_rebalance_notification_order.success! }.to raise_error(AASM::InvalidTransition) }
      it { expect { investment_portfolio_rebalance_notification_order.reprocess! }.to raise_error(AASM::InvalidTransition) }
    end

    describe 'error state' do
      let(:investment_portfolio_rebalance_notification_order) { create(:investment_portfolio_rebalance_notification_order, :error) }

      it { expect(investment_portfolio_rebalance_notification_order).to be_error }
      it { expect { investment_portfolio_rebalance_notification_order.process! }.to raise_error(AASM::InvalidTransition) }
      it { expect { investment_portfolio_rebalance_notification_order.error! }.to raise_error(AASM::InvalidTransition) }
      it { expect { investment_portfolio_rebalance_notification_order.success! }.to raise_error(AASM::InvalidTransition) }
      it { expect { investment_portfolio_rebalance_notification_order.reprocess! }.not_to raise_error }
      it { expect { investment_portfolio_rebalance_notification_order.reprocess! }.to change { investment_portfolio_rebalance_notification_order.status }.from('error').to('processing') }
    
      it 'increments retry_count and clean error_message when reprocess event is triggered' do
        order = create(:investment_portfolio_rebalance_notification_order, :error)
        order.reprocess!
  
        expect(order.reload.error_message).to be_nil
        expect(order.reload.retry_count).to eq(1)
      end
    end
  end
end
