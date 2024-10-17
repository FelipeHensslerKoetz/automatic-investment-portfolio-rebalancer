require 'rails_helper'

RSpec.describe Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationJob, type: :job do
  describe 'sidekiq_options' do
    it 'sets the queue to global_investment_portfolio_rebalance_notification_orders_notification' do
      expect(described_class.get_sidekiq_options['queue']).to eq('global_investment_portfolio_rebalance_notification_orders_notification')
    end

    it 'sets the retry option to false' do
      expect(described_class.get_sidekiq_options['retry']).to eq(false)
    end
  end

  describe 'includes' do
    it 'includes Sidekiq::Job' do
      expect(described_class.ancestors).to include(Sidekiq::Job)
    end
  end

  describe '#perform' do
    subject(:notification_job) { described_class.new }

    context 'when the investment portfolio rebalance notification order does not exist' do 
      before do
        allow(Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationService).to receive(:call).and_return(true)
        notification_job.perform(0)
      end

      it 'does not call the NotificationService' do
        expect(Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationService).not_to have_received(:call)
      end
    end

    context 'when the investment portfolio rebalance notification order exists' do
      let(:investment_portfolio_rebalance_notification_order) { create(:investment_portfolio_rebalance_notification_order, :with_email_investment_portfolio_rebalance_notification_option) }

      before do
        allow(Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationService).to receive(:call).and_return(true)
        notification_job.perform(investment_portfolio_rebalance_notification_order.id)
      end

      it 'calls the NotificationService' do
        expect(Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationService).to have_received(:call).with(investment_portfolio_rebalance_notification_order: investment_portfolio_rebalance_notification_order)
      end
    end
  end
end