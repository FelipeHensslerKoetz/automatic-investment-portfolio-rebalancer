# frozen_string_literal: true

module Api
  module V1
    class InvestmentPortfoliosController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_investment_portfolio, only: %i[show update destroy investment_portfolio_assets]

      def index
        @investment_portfolios = current_api_user.investment_portfolios

        render json: @investment_portfolios, status: :ok
      end

      # TODO: Display investment_portfolio total value and all assets quotation, considering investment_portfolio currency code passed as parameter
      def show
        render json: @investment_portfolio, status: :ok
      end

      def create
        @investment_portfolio = current_api_user.investment_portfolios.new(investment_portfolio_params)

        if @investment_portfolio.save
          render json: @investment_portfolio, status: :created
        else
          render json: { error: @investment_portfolio.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      # TODO: Do not allow to update investment_portfolio name if it has rebalance orders scheduled or processing
      def update
        if @investment_portfolio.update(investment_portfolio_params)
          render json: @investment_portfolio, status: :ok
        else
          render json: { error: @investment_portfolio.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      def destroy
        if @investment_portfolio.destroy
          head :no_content
        else
          render json: { error: 'InvestmentPortfolio not deleted' }, status: :unprocessable_entity
        end
      end

      def investment_portfolio_assets
        System::InvestmentPortfolioAssets::CreatorService.call(investment_portfolio: @investment_portfolio,
                                                       investment_portfolio_assets_attributes: investment_portfolio_assets_params['investment_portfolio_assets_attributes'])
        render json: @investment_portfolio.reload.investment_portfolio_assets, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def set_investment_portfolio
        @investment_portfolio = current_api_user.investment_portfolios.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'InvestmentPortfolio not found' }, status: :not_found
      end

      def investment_portfolio_params
        params.require(:investment_portfolio).permit(:name, :description)
      end

      def investment_portfolio_assets_params
        params.require(:investment_portfolio).permit(investment_portfolio_assets_attributes: %i[asset_id quantity target_allocation_weight_percentage asset_ticker_symbol target_variation_limit_percentage _destroy])
      end
    end
  end
end
