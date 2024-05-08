# frozen_string_literal: true

module AssetPrices
  class ConvertParityService
    attr_reader :asset_price, :output_currency

    def self.call(asset_price_id:, output_currency_id:)
      new(asset_price_id:, output_currency_id:).call
    end

    def initialize(asset_price_id:, output_currency_id:)
      @asset_price = AssetPrice.includes(:currency).find_by(id: asset_price_id)
      @output_currency = Currency.find_by(id: output_currency_id)
    end

    def call
      check_parity_conversion_requirements

      price_in_output_currency
    end

    private

    def current_currency_parity_exchange_rate
      @current_currency_parity_exchange_rate ||= currency_parity.currency_parity_exchange_rates.updated.order(reference_date: :desc).first
    end

    def currency_parity
      @currency_parity ||= CurrencyParity.find_by(currency_from: output_currency,
                                                  currency_to: input_currency)
    end

    def exchange_rate
      @exchange_rate ||= current_currency_parity_exchange_rate.exchange_rate
    end

    def input_currency
      @input_currency ||= asset_price.currency
    end

    def check_parity_conversion_requirements
      validate_arguments
      validate_asset_price
      validate_currency_parity
    end

    def validate_arguments
      raise ArgumentError, 'asset_price argument must be an AssetPrice' unless asset_price.is_a?(AssetPrice)
      raise ArgumentError, 'output_currency argument must be a Currency' unless output_currency.is_a?(Currency)
    end

    def validate_asset_price
      raise AssetPriceOutdatedError.new(asset_price:) unless asset_price.updated?
    end

    def validate_currency_parity
      return if input_currency == output_currency

      raise CurrencyParityMissingError.new(currency_from: output_currency, currency_to: input_currency) if currency_parity.blank?
      raise CurrencyParityOutdatedError.new(currency_parity:) unless current_currency_parity_exchange_rate
    end

    def price_in_output_currency
      return asset_price.price if input_currency == output_currency

      asset_price.price.to_d / exchange_rate.to_d
    end
  end
end
