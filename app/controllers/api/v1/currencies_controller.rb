# frozen_string_literal: true

module Api
  module V1
    class CurrenciesController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_currency, only: %i[show]

      def index
        @currencies = Currency.all
        render json: @currencies, status: :ok
      end

      def show
        if @currency
          render json: @currency, status: :ok
        else
          render json: nil, status: :not_found
        end
      end

      private

      def set_currency
        @currency = Currency.find_by(id: params[:id])
      end
    end
  end
end
