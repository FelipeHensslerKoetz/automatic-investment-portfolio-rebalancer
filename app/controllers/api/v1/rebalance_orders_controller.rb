# frozen_string_literal: true

module Api
  module V1
    class RebalanceOrdersController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_rebalance_order, only: %i[show update destroy]

      def index
        @rebalance_orders = current_api_user.rebalance_orders

        render json: @rebalance_orders, status: :ok
      end

      def show
        render json: @rebalance_order, status: :ok
      end

      def create
        @rebalance_order = current_api_user.rebalance_orders.new(rebalance_order_params)
        unless investment_portfolio_belong_to_user?(rebalance_order_params[:investment_portfolio_id])
          @rebalance_order.investment_portfolio_id = nil
        end

        if @rebalance_order.save
          render json: @rebalance_order, status: :created
        else
          render json: { error: @rebalance_order.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      def update
        params = rebalance_order_params.to_h

        if params['investment_portfolio_id'] && !investment_portfolio_belong_to_user?(params['investment_portfolio_id'])
          params['investment_portfolio_id'] = nil
        end

        return render json: { error: 'RebalanceOrder in process' }, status: :unprocessable_entity unless @rebalance_order.pending?

        if @rebalance_order.update(params)
          render json: @rebalance_order, status: :ok
        else
          render json: { error: @rebalance_order.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      def destroy
        return render json: { error: 'RebalanceOrder not deleted' }, status: :unprocessable_entity unless @rebalance_order.pending?

        if @rebalance_order.destroy
          head :no_content
        else
          render json: { error: 'RebalanceOrder not deleted' }, status: :unprocessable_entity
        end
      end

      private

      def set_rebalance_order
        @rebalance_order = current_api_user.rebalance_orders.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'RebalanceOrder not found' }, status: :not_found
      end

      def rebalance_order_params
        params.require(:rebalance_order).permit(:investment_portfolio_id, :kind, :amount, :scheduled_at)
      end

      def investment_portfolio_belong_to_user?(investment_portfolio_id)
        current_api_user.investment_portfolios.exists?(id: investment_portfolio_id)
      end
    end
  end
end
