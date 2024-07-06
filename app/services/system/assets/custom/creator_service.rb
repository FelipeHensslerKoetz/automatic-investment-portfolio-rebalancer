# frozen_string_literal: true

module System
  module Assets
    module Custom
      class CreatorService
        attr_reader :user, :custom_asset_params

        def initialize(user:, custom_asset_params:)
          @user = user
          @custom_asset_params = custom_asset_params
        end

        def self.call(user:, custom_asset_params:)
          new(user:, custom_asset_params:).call
        end

        def call
          create_asset_and_asset_price
        end

        private

        def create_asset_and_asset_price
          ActiveRecord::Base.transaction do
            asset = create_asset
            create_asset_price(asset)

            asset
          end
        end

        def create_asset
          user.assets.create!(
            ticker_symbol: "#{user.email} - #{custom_asset_params[:name]}",
            name: custom_asset_params[:name],
            custom: true,
            kind: 'custom'
          )
        end

        def create_asset_price(asset)
          asset.asset_prices.create!(
            ticker_symbol: "#{user.email} - #{custom_asset_params[:name]}",
            price: custom_asset_params[:price],
            currency:,
            last_sync_at: Time.zone.now,
            reference_date: Time.zone.now,
            status: 'updated'
          )
        end

        def currency
          @currency = Currency.find_by(code: custom_asset_params[:currency_code])
        end
      end
    end
  end
end
