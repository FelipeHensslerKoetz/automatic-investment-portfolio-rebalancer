# frozen_string_literal: true

module Global
  module RebalanceOrders
    class AutomaticRebalanceByRecurrenceService
      attr_reader :automatic_rebalance_option

      def self.call(automatic_rebalance_option:)
        new(automatic_rebalance_option:).call
      end

      def initialize(automatic_rebalance_option:)
        @automatic_rebalance_option = automatic_rebalance_option
      end

      def call
        validate_automatic_rebalance_option
        check_automatic_rebalance_creation
      rescue StandardError => e
        create_error_log(e)
      end

      private

      def validate_automatic_rebalance_option
        unless automatic_rebalance_option.is_a?(AutomaticRebalanceOption)
          raise ArgumentError,
                'automatic_rebalance_option is not an automatic rebalance option'
        end
        raise ArgumentError, 'automatic_rebalance_option is not a recurrence type' unless automatic_rebalance_option.kind == 'recurrence'
      end

      def check_automatic_rebalance_creation
        if first_automatic_rebalance_by_recurrence?
          create_rebalance_order(automatic_rebalance_option.start_date)
        elsif last_rebalance_order_was_processed?
          create_rebalance_order(last_rebalance_order.scheduled_at + automatic_rebalance_option.recurrence_days.days)
        end
      end

      def first_automatic_rebalance_by_recurrence?
        RebalanceOrder.where(
          investment_portfolio: automatic_rebalance_option.investment_portfolio,
          user: automatic_rebalance_option.investment_portfolio.user,
          created_by_system: true
        ).where(scheduled_at: automatic_rebalance_option.start_date).empty?
      end

      def create_rebalance_order(scheduled_at)
        RebalanceOrder.create!(
          investment_portfolio: automatic_rebalance_option.investment_portfolio,
          user: automatic_rebalance_option.investment_portfolio.user,
          status: 'pending',
          kind: automatic_rebalance_option.rebalance_order_kind,
          amount: automatic_rebalance_option.amount,
          scheduled_at:,  
          created_by_system: true
        )
      end

      def last_rebalance_order
        @last_rebalance_order = RebalanceOrder.where(
          investment_portfolio: automatic_rebalance_option.investment_portfolio,
          user: automatic_rebalance_option.investment_portfolio.user,
          created_by_system: true
        ).order(created_at: :desc).first
      end

      def last_rebalance_order_was_processed?
        last_rebalance_order.status != 'pending'
      end

      def create_error_log(error)
        System::Logs::CreatorService.create_log(kind: :error, data: error_message(error))
      end

      def error_message(error)
        {
          context: "#{self.class} - automatic_rebalance_option=#{automatic_rebalance_option}",
          message: "#{error.class}: #{error.message}",
          backtrace: error.backtrace
        }
      end
    end
  end
end
