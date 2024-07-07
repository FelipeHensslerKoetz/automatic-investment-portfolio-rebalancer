# frozen_string_literal: true

module Api
  module V1
    class CustomerSupportItemsController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_customer_support_item, only: %i[show update destroy]

      # GET /customer_support_items
      def index
        @customer_support_items = current_api_user.customer_support_items

        render json: @customer_support_items
      end

      # GET /customer_support_items/1
      def show
        render json: @customer_support_item
      end

      # POST /customer_support_items
      def create
        @customer_support_item = current_api_user.customer_support_items.build(customer_support_item_params)

        if @customer_support_item.save
          render json: @customer_support_item, status: :created
        else
          render json: @customer_support_item.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /customer_support_items/1
      def update
        if @customer_support_item.update(customer_support_item_params)
          render json: @customer_support_item
        else
          render json: @customer_support_item.errors, status: :unprocessable_entity
        end
      end

      # DELETE /customer_support_items/1
      def destroy
        if @customer_support_item.destroy
          head :no_content
        else
          render json: { error: 'Customer Support Item not deleted' }, status: :unprocessable_entity
        end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_customer_support_item
        @customer_support_item = current_api_user.customer_support_items.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Customer Support Item not found' }, status: :not_found
      end

      # Only allow a list of trusted parameters through.
      def customer_support_item_params
        params.require(:customer_support_item).permit(:title, :description)
      end
    end
  end
end
