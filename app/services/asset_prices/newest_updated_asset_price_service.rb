# frozen_string_literal: true

module AssetPrices
  class NewestUpdatedAssetPriceService
    attr_reader :asset, :currency

    def initialize(asset:, currency:)
      @asset = asset
      @currency = currency
    end

    def self.call(asset:, currency:)
      new(asset:, currency:).call
    end

    def call
      validate_arguments
      fetch_newest_updated_asset_price
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
      raise ArgumentError, 'Currency must be present' unless currency.is_a?(Currency)
    end

    def fetch_newest_updated_asset_price
      raise AssetOutdatedError.new(asset:) if updated_asset_prices.blank?

      updated_asset_prices.max_by(&:reference_date)
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
