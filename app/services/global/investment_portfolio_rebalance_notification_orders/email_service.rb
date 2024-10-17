module Global 
  module InvestmentPortfolioRebalanceNotificationOrders 
    class EmailService
      attr_reader :email, :rebalance

      def initialize(email:, rebalance:)
        @email = email
        @rebalance = rebalance
      end

      def self.call(email:, rebalance:)
        new(email:, rebalance:).call
      end

      def call
        UserMailer.rebalance_notification_email(email, rebalance).deliver_now

        { success: true }
      rescue StandardError => e
        { success: false, response: e.message }
      end
    end
  end
end