require 'rails_helper'

RSpec.describe Global::InvestmentPortfolioRebalanceNotificationOrders::CheckNotificationOrdersJob, type: :job do
  describe 'sidekiq_options' do
    it 'sets the queue to global_investment_portfolio_rebalance_notification_orders_check' do
      expect(described_class.get_sidekiq_options['queue']).to eq('global_investment_portfolio_rebalance_notification_orders_check')
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
    subject(:check_notification_orders_job) { described_class.new }

    context 'when there are no pending or error investment portfolio rebalance notification orders' do
      before do 
        allow(Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationJob).to receive(:perform_async).and_return(true)
        check_notification_orders_job.perform
      end

      it 'does not call the NotificationJob' do
        expect(Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationJob).not_to have_received(:perform_async)
      end
    end

    context 'when there are pending or error investment portfolio rebalance notification orders' do
      let!(:pending_investment_portfolio_rebalance_notification_order) do 
        create(:investment_portfolio_rebalance_notification_order, :with_webhook_investment_portfolio_rebalance_notification_option, :pending)
      end

      let!(:error_investment_portfolio_rebalance_notification_order) do
        create(:investment_portfolio_rebalance_notification_order, :with_email_investment_portfolio_rebalance_notification_option, :error)
      end

      before do
        allow(Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationJob).to receive(:perform_async).with(pending_investment_portfolio_rebalance_notification_order.id).and_return(true)
        allow(Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationJob).to receive(:perform_async).with(error_investment_portfolio_rebalance_notification_order.id).and_return(true)
        check_notification_orders_job.perform
      end

      it 'calls the NotificationJob for the pending investment portfolio rebalance notification order' do
        expect(Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationJob).to have_received(:perform_async).with(pending_investment_portfolio_rebalance_notification_order.id).once
        expect(Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationJob).to have_received(:perform_async).with(error_investment_portfolio_rebalance_notification_order.id).once
      end
    end
  end
end