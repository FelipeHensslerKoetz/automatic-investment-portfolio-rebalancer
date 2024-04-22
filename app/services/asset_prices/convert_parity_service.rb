# frozen_string_literal: true

module AssetPrices
  class ConvertParityService
    attr_reader :asset_price, :output_currency, :input_currency

    def self.call(asset_price:, output_currency:)
      new(asset_price:, output_currency:).call
    end

    def initialize(asset_price:, output_currency:)
      @asset_price = asset_price
      @input_currency = asset_price&.currency
      @output_currency = output_currency
    end

    def call
      check_calculation_requirements

      price_in_output_currency
    end

    private

    def check_calculation_requirements
      validate_argument_classes
      validate_asset_price
      validate_currency_parity_exchange_rate
    end

    def validate_argument_classes
      raise ArgumentError, 'asset_price argument must be an AssetPrice' unless asset_price.is_a?(AssetPrice)
      raise ArgumentError, 'output_currency argument must be a Currency' unless output_currency.is_a?(Currency)
    end

    def validate_asset_price
      raise AssetPriceOutdatedError.new(asset_price:) unless asset_price.updated?
    end

    def validate_currency_parity_exchange_rate
      return if input_currency == output_currency

      raise CurrencyParityMissingError.new(currency_from: output_currency, currency_to: input_currency) if currency_parity.blank?
      raise CurrencyParityOutdatedError.new(currency_parity:) unless currency_parity.current_exchange_rate
    end

    def price_in_output_currency
      return asset_price.price if input_currency == output_currency

      asset_price.price.to_d / currency_parity_exchange_rate.exchange_rate.to_d
    end

    def currency_parity
      @currency_parity ||= CurrencyParity.find_by(currency_from: output_currency, currency_to: input_currency)
    end

    def currency_parity_exchange_rate
      @currency_parity_exchange_rate ||= currency_parity.newest_currency_parity_exchange_rate_by_reference_date
    end
  end
end
