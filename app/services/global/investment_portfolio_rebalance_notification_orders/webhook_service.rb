# frozen_string_literal: true

module Global
  module InvestmentPortfolioRebalanceNotificationOrders
    class WebhookService
      attr_reader :url, :http_method, :header, :rebalance, :params

      def self.call(params)
        new(params).call
      end

      def initialize(params)
        @params = params
        @url = params[:url]
        @header = params[:header]
        @rebalance = params[:rebalance]
      end

      def call
        return { response: "Invalid Params: #{params}", success: false } unless valid_params?

        post
      end

      private

      def valid_params?
        url.is_a?(String) && header.is_a?(Hash) && rebalance.is_a?(String)
      end

      def post
        response = Faraday.post(url, rebalance, header)

        { response: response.body.to_s, success: true }
      rescue Faraday::Error => e
        { response: e.message, success: false }
      end
    end
  end
end
