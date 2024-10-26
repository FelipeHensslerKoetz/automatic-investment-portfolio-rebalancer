# frozen_string_literal: true

module Global
  module InvestmentPortfolioRebalanceNotificationOrders
    class NotificationService
      attr_reader :investment_portfolio_rebalance_notification_order

      def self.call(investment_portfolio_rebalance_notification_order:)
        new(investment_portfolio_rebalance_notification_order:).call
      end

      def initialize(investment_portfolio_rebalance_notification_order:)
        @investment_portfolio_rebalance_notification_order = investment_portfolio_rebalance_notification_order
      end

      def call
        validate_investment_portfolio_rebalance_notification_order
        process_or_reprocess_investment_portfolio_rebalance_notification_order

        notify_user
      rescue StandardError => e
        create_error_log(e)
      end

      private

      def investment_portfolio_rebalance_notification_option
        @investment_portfolio_rebalance_notification_option ||= investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option
      end

      def rebalance 
        @rebalance ||= investment_portfolio_rebalance_notification_order.rebalance
      end

      def notify_user
        notification_response = nil 

        if investment_portfolio_rebalance_notification_option.webhook?
          notification_response = Global::InvestmentPortfolioRebalanceNotificationOrders::WebhookService.call(
            webhook_payload
          )
        elsif investment_portfolio_rebalance_notification_option.email?
          notification_response = Global::InvestmentPortfolioRebalanceNotificationOrders::EmailService.call(
            email: investment_portfolio_rebalance_notification_option.email, 
            rebalance: rebalance
          )
        end

        if notification_response[:success]
          investment_portfolio_rebalance_notification_order.success!
        else 
          investment_portfolio_rebalance_notification_order.update(error_message: notification_response[:response])
          investment_portfolio_rebalance_notification_order.error!
        end
      end

      def validate_investment_portfolio_rebalance_notification_order
        unless investment_portfolio_rebalance_notification_order.is_a?(InvestmentPortfolioRebalanceNotificationOrder)
          raise ArgumentError,
                'Invalid investment_portfolio_rebalance_notification_order'
        end
        unless investment_portfolio_rebalance_notification_order.may_process? || investment_portfolio_rebalance_notification_order.may_reprocess?
          raise StandardError,
                'Invalid investment_portfolio_rebalance_notification_order status'
        end
      end

      def process_or_reprocess_investment_portfolio_rebalance_notification_order
        investment_portfolio_rebalance_notification_order.process! if investment_portfolio_rebalance_notification_order.may_process?
        investment_portfolio_rebalance_notification_order.reprocess! if investment_portfolio_rebalance_notification_order.may_reprocess?
      end

      def create_error_log(error)
        error_log = System::Logs::CreatorService.create_log(kind: :error, data: error_message(error))

        return unless investment_portfolio_rebalance_notification_order.present?

        investment_portfolio_rebalance_notification_order.error!
        investment_portfolio_rebalance_notification_order.update!(error_message: error_log['data']['message'])
      end

      def error_message(error)
        {
          context: "#{self.class} - investment_portfolio_rebalance_notification_order_id=#{investment_portfolio_rebalance_notification_order&.id}",
          message: "#{error.class}: #{error.message}",
          backtrace: error.backtrace
        }
      end

      def webhook_payload
        {
          url: investment_portfolio_rebalance_notification_option.url,
          header: investment_portfolio_rebalance_notification_option.header,
          rebalance: rebalance.to_json
        }
      end
    end
  end
end
