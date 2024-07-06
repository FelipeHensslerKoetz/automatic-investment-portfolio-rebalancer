# frozen_string_literal: true

module Api
  module V1
    class CustomAssetsController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_custom_asset, only: %i[show update destroy]

      def index
        @custom_assets = current_api_user.assets

        render json: @custom_assets, status: :ok
      end

      def show
        if @custom_asset
          render json: @custom_asset, status: :ok
        else
          render json: { error: 'CustomAsset not found' }, status: :not_found
        end
      end

      def create
        @custom_asset = System::Assets::Custom::CreatorService.call(user: current_api_user, custom_asset_params:)

        render json: @custom_asset, status: :created
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def update
        if @custom_asset
          begin
            System::Assets::Custom::UpdateService.call(custom_asset: @custom_asset, custom_asset_params:)

            render json: @custom_asset, status: :ok
          rescue StandardError => e
            render json: { error: e.message }, status: :unprocessable_entity
          end
        else
          render json: { error: 'CustomAsset not found' }, status: :not_found
        end
      end

      def destroy
        if @custom_asset
          return head :no_content if @custom_asset.destroy

          render json: { error: 'CustomAsset not deleted' }, status: :unprocessable_entity
        else
          render json: { error: 'CustomAsset not found' }, status: :not_found
        end
      end

      private

      def set_custom_asset
        @custom_asset = current_api_user.assets.find_by(id: params[:id])
      end

      def custom_asset_params
        params.require(:custom_asset).permit(:name, :currency_code, :price)
      end
    end
  end
end
