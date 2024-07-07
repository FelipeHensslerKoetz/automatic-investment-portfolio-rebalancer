# frozen_string_literal: true

module Api
  module V1
    class CustomerSupportItemMessagesController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_customer_support_item_message, only: %i[show]
      before_action :set_customer_support_item, only: %i[create]

      # GET /customer_support_item_messages
      def index
        @customer_support_item_messages = current_api_user.customer_support_item_messages

        render json: @customer_support_item_messages
      end

      # GET /customer_support_item_messages/1
      def show
        render json: @customer_support_item_message
      end

      # POST /customer_support_item_messages
      def create
        @customer_support_item_message = CustomerSupportItemMessage.new(customer_support_item_message_final_params)

        if @customer_support_item_message.save
          render json: @customer_support_item_message, status: :created
        else
          render json: @customer_support_item_message.errors, status: :unprocessable_entity
        end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_customer_support_item_message
        @customer_support_item_message = CustomerSupportItemMessage.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Customer support item message not found' }, status: :not_found
      end

      # Only allow a list of trusted parameters through.
      def customer_support_item_message_params
        params.require(:customer_support_item_message).permit(:customer_support_item_id, :message)
      end

      def set_customer_support_item
        @customer_support_item = if current_api_user.admin?
                                   CustomerSupportItem.find(params[:customer_support_item_message][:customer_support_item_id])
                                 else
                                   current_api_user.customer_support_items.find(
                                     params[:customer_support_item_message][:customer_support_item_id]
                                   )
                                 end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Customer support item not found' }, status: :not_found
      end

      def customer_support_item_message_final_params
        {
          user_id: current_api_user.id,
          customer_support_item_id: @customer_support_item.id,
          message: customer_support_item_message_params[:message]
        }
      end
    end
  end
end
