# frozen_string_literal: true

module Global
  module InvestmentPortfolioRebalanceNotificationOrders
    class CheckNotificationOrdersJob
      include Sidekiq::Job

      sidekiq_options queue: 'global_investment_portfolio_rebalance_notification_orders_check', retry: false

      def perform
        InvestmentPortfolioRebalanceNotificationOrder.pending_or_with_error.each do |investment_portfolio_rebalance_notification_order|
          Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationJob.perform_async(investment_portfolio_rebalance_notification_order.id)
        end
      end
    end
  end
end
