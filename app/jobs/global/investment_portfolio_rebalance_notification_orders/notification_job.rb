module Global 
  module InvestmentPortfolioRebalanceNotificationOrders 
    class NotificationJob 
      include Sidekiq::Job

      sidekiq_options queue: 'global_investment_portfolio_rebalance_notification_orders_notification', retry: false

      def perform(investment_portfolio_rebalance_notification_order_id)
        investment_portfolio_rebalance_notification_order = InvestmentPortfolioRebalanceNotificationOrder.find_by(
          id: investment_portfolio_rebalance_notification_order_id)

        return unless investment_portfolio_rebalance_notification_order.present?

        Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationService.call(
          investment_portfolio_rebalance_notification_order: investment_portfolio_rebalance_notification_order)
      end
    end
  end
end