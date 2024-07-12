# frozen_string_literal: true

module Api
  module V1
    class AutomaticRebalanceOptionsController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_automatic_rebalance_option, only: %i[show destroy]

      def index
        @automatic_rebalance_options = current_api_user.automatic_rebalance_options

        render json: @automatic_rebalance_options
      end

      def show
        render json: @automatic_rebalance_option
      end

      def create
        @automatic_rebalance_option = current_api_user
                                      .automatic_rebalance_options
                                      .build(automatic_rebalance_option_params.except(:investment_portfolio_id))

        return render json: { error: 'Investment portfolio not found' }, status: :not_found if investment_portfolio.blank?

        @automatic_rebalance_option.investment_portfolio = investment_portfolio

        if @automatic_rebalance_option.save
          render json: @automatic_rebalance_option, status: :created
        else
          render json: @automatic_rebalance_option.errors, status: :unprocessable_entity
        end
      end

      def destroy
        investment_portfolio = @automatic_rebalance_option.investment_portfolio

        if @automatic_rebalance_option.destroy
          remove_all_pending_rebalance_orders(investment_portfolio)
          head :no_content
        else
          render json: { error: @automatic_rebalance_option.errors }, status: :unprocessable_entity
        end
      end

      private

      def automatic_rebalance_option_params
        params.require(:automatic_rebalance_option).permit(:kind, :start_date, :recurrence_days, :investment_portfolio_id)
      end

      def set_automatic_rebalance_option
        @automatic_rebalance_option = current_api_user.automatic_rebalance_options.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Automatic rebalance option not found' }, status: :not_found
      end

      def investment_portfolio
        @investment_portfolio ||= current_api_user.investment_portfolios.find_by(
          id: automatic_rebalance_option_params[:investment_portfolio_id]
        )
      end

      def remove_all_pending_rebalance_orders(investment_portfolio)
        RebalanceOrder.where(investment_portfolio:, created_by_system: true, status: 'pending').destroy_all
      end
    end
  end
end
