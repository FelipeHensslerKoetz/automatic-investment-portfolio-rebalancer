# frozen_string_literal: true

module System
  module AssetPrices
    class UpdatedAssetPriceService
      attr_reader :asset, :currency

      PARTNER_RESOURCE_PRIORITY = %w[br_api_assets hg_brasil_assets].freeze

      def initialize(asset:)
        @asset = asset
        @currency = Currency.default_currency
      end

      def self.call(asset:)
        new(asset:).call
      end

      def call
        validate_arguments
        updated_asset_price
      end

      private

      def updated_asset_prices
        @updated_asset_prices ||= asset.asset_prices.updated.filter do |asset_price|
          if asset_price_with_same_currency?(asset_price)
            true
          else
            check_parity_requirements(asset_price)
          end
        end.compact_blank
      end

      def validate_arguments
        raise ArgumentError, 'Asset must be present' unless asset.is_a?(Asset)
      end

      def updated_asset_price
        raise ::Assets::OutdatedError.new(asset:) if updated_asset_prices.blank?

        updated_asset_price_by_partner_resource_priority(updated_asset_prices)
      end

      def updated_asset_price_by_partner_resource_priority(updated_asset_prices)
        PARTNER_RESOURCE_PRIORITY.each do |partner_resource|
          updated_asset_price = updated_asset_prices.find { |asset_price| asset_price.partner_resource.slug == partner_resource }

          return updated_asset_price if updated_asset_price.present?
        end
        nil
      end

      def asset_price_with_same_currency?(asset_price)
        asset_price.currency == currency
      end

      def check_parity_requirements(asset_price)
        currency_parity_exchange_rates_updated?(primary_currency_parity(asset_price.currency)) ||
          currency_parity_exchange_rates_updated?(secondary_currency_parity(asset_price.currency))
      end

      def currency_parity_exchange_rates_updated?(currency_parity)
        return false if currency_parity.blank?

        currency_parity.currency_parity_exchange_rates.updated.any?
      end

      def primary_currency_parity(asset_currency)
        CurrencyParity.find_by(currency_from: asset_currency, currency_to: currency)
      end

      def secondary_currency_parity(asset_currency)
        CurrencyParity.find_by(currency_from: currency, currency_to: asset_currency)
      end
    end
  end
end
