# frozen_string_literal: true

module Api
  module V1
    class AssetsController < ApplicationController
      before_action :authenticate_api_user!

      def index
        @assets = Asset.global

        render json: @assets, status: :ok
      end

      def show
        @asset = Asset.global.find_by(id: params[:id])

        if @asset
          render json: @asset, status: :ok
        else
          render json: nil, status: :not_found
        end
      end

      def search
        @assets = Asset.global.where(
          'name ILIKE :asset or ticker_symbol ILIKE :asset', asset: "%#{params[:asset]}%"
        )

        render json: @assets, status: :ok
      end

      def deep_search
        AssetDiscoveryJob.perform_async(params[:asset])

        render json: { message: 'Asset discovery job has been scheduled' }, status: :ok
      end
    end
  end
end
