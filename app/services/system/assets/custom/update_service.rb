# frozen_string_literal: true

module System
  module Assets
    module Custom
      class UpdateService
        attr_reader :custom_asset, :custom_asset_params

        def initialize(custom_asset:, custom_asset_params:)
          @custom_asset = custom_asset
          @custom_asset_params = custom_asset_params
        end

        def self.call(custom_asset:, custom_asset_params:)
          new(custom_asset:, custom_asset_params:).call
        end

        def call
          check_custom_asset
          check_rebalance_order_in_processing
          update_asset_and_asset_price
        end

        private

        def check_custom_asset
          return if custom_asset.custom?

          raise StandardError, 'Asset must be custom'
        end

        def check_rebalance_order_in_processing
          return unless user.rebalance_orders.processing.any? || user.rebalance_orders.scheduled.any?

          raise StandardError, 'Asset cannot be updated while there is a RebalanceOrder being processed or scheduled'
        end

        def user
          @user = custom_asset.user
        end

        def update_asset_and_asset_price
          ActiveRecord::Base.transaction do
            update_asset
            update_asset_price
          end

          custom_asset
        end

        def update_asset
          custom_asset.update!(asset_params)
        end

        def asset_params
          base_params = {}
          base_params[:name] = custom_asset_params[:name]
          base_params[:ticker_symbol] = "#{custom_asset.user.email} - #{custom_asset_params[:name]}" if custom_asset_params[:name].present?
          base_params.compact
        end

        def update_asset_price
          asset_price = custom_asset.asset_prices.first

          asset_price.update!(asset_price_params)
        end

        def asset_price_params
          base_params = {
            last_sync_at: Time.zone.now,
            reference_date: Time.zone.now,
            status: 'updated'
          }

          base_params[:ticker_symbol] = "#{custom_asset.user.email} - #{custom_asset_params[:name]}" if custom_asset_params[:name].present?
          base_params[:price] = custom_asset_params[:price] if custom_asset_params[:price].present?
          base_params[:currency] = currency if custom_asset_params[:currency_code].present?

          base_params.compact
        end

        def currency
          @currency = Currency.find_by!(code: custom_asset_params[:currency_code])
        end
      end
    end
  end
end
