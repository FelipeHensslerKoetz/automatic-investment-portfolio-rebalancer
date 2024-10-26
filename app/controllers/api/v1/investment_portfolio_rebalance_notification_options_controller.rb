# frozen_string_literal: true

module Api
  module V1
    class InvestmentPortfolioRebalanceNotificationOptionsController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_investment_portfolio_rebalance_notification_option, only: %i[show update destroy]

      def index
        @investment_portfolio_rebalance_notification_options = current_api_user.investment_portfolio_rebalance_notification_options

        render json: @investment_portfolio_rebalance_notification_options
      end

      def show
        render json: @investment_portfolio_rebalance_notification_option
      end

      def create
        @investment_portfolio_rebalance_notification_option = current_api_user.investment_portfolio_rebalance_notification_options.build(
          investment_portfolio_rebalance_notification_option_formatted_params
        )

        if @investment_portfolio_rebalance_notification_option.save
          render json: @investment_portfolio_rebalance_notification_option, status: :created
        else
          render json: @investment_portfolio_rebalance_notification_option.errors, status: :unprocessable_entity
        end
      rescue JSON::ParserError
        render json: { error: 'Invalid JSON format' }, status: :unprocessable_entity
      end

      def update
        if @investment_portfolio_rebalance_notification_option.update(investment_portfolio_rebalance_notification_option_formatted_params)
          render json: @investment_portfolio_rebalance_notification_option
        else
          render json: @investment_portfolio_rebalance_notification_option.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if @investment_portfolio_rebalance_notification_option.destroy
          head :no_content
        else
          render json: { error: 'Investment Portfolio Rebalance Notification Option not deleted' }, status: :unprocessable_entity
        end
      end

      private

      def set_investment_portfolio_rebalance_notification_option
        @investment_portfolio_rebalance_notification_option = current_api_user.investment_portfolio_rebalance_notification_options.find(
          params[:id]
        )
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Investment Portfolio Rebalance Notification Option not found' }, status: :not_found
      end

      def investment_portfolio_rebalance_notification_option_params
        params.require(:investment_portfolio_rebalance_notification_option).permit(
          :investment_portfolio_id,
          :kind,
          :name,
          :url,
          :header,
          :email
        )
      end

      def investment_portfolio_rebalance_notification_option_formatted_params
        if investment_portfolio_rebalance_notification_option_params[:header]&.present?
          parsed_header = JSON.parse(investment_portfolio_rebalance_notification_option_params[:header]) # TODO: checar localmente
        end

        {
          investment_portfolio_id: check_investment_portfolio_id,
          kind: investment_portfolio_rebalance_notification_option_params[:kind],
          name: investment_portfolio_rebalance_notification_option_params[:name],
          url: investment_portfolio_rebalance_notification_option_params[:url],
          email: investment_portfolio_rebalance_notification_option_params[:email],
          header: parsed_header
        }.compact
      end

      def check_investment_portfolio_id
        if current_api_user.investment_portfolios.find_by(
          id: investment_portfolio_rebalance_notification_option_params[:investment_portfolio_id]
        )
          investment_portfolio_rebalance_notification_option_params[:investment_portfolio_id]
        end
      end
    end
  end
end
