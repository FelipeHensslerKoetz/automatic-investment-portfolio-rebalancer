# frozen_string_literal: true

module System
  module AssetPrices
    class ConvertParityService
      attr_reader :asset_price, :output_currency

      def self.call(asset_price:)
        new(asset_price:).call
      end

      def initialize(asset_price:)
        @asset_price = asset_price
        @output_currency = Currency.default_currency
      end

      def call
        validate_parity_conversion_requirements

        compute_asset_price_in_output_currency
      end

      private

      def input_currency
        @input_currency ||= asset_price.currency
      end

      def output_to_input_currency_parity
        @output_to_input_currency_parity ||= CurrencyParity.find_by(currency_from: output_currency,
                                                                    currency_to: input_currency)
      end

      def output_to_input_currency_parity_exchange_rate
        @output_to_input_currency_parity_exchange_rate ||=
          fetch_updated_currency_parity_exchange_rate(output_to_input_currency_parity)
      end

      def input_to_output_currency_parity
        @input_to_output_currency_parity ||= CurrencyParity.find_by(currency_from: input_currency,
                                                                    currency_to: output_currency)
      end

      def input_to_output_currency_parity_exchange_rate
        @input_to_output_currency_parity_exchange_rate ||= fetch_updated_currency_parity_exchange_rate(input_to_output_currency_parity)
      end

      def validate_parity_conversion_requirements
        validate_arguments
        validate_asset_price_up_to_date
        validate_any_currency_parity_available unless asset_price_already_in_output_currency?
        validate_currency_parities_exchange_rate_up_to_date unless asset_price_already_in_output_currency?
      end

      def validate_arguments
        raise ArgumentError, 'Invalid asset_price argument' unless asset_price.is_a?(AssetPrice)
      end

      def validate_asset_price_up_to_date
        raise ::AssetPrices::OutdatedError.new(asset_price:) unless asset_price.updated?
      end

      def validate_any_currency_parity_available
        return if any_currency_parity_available?

        raise CurrencyParities::MissingError,
              "Missing currency parities for conversion: #{input_currency.code} to #{output_currency.code} or
               #{output_currency.code} to #{input_currency.code}"
      end

      def any_currency_parity_available?
        output_to_input_currency_parity.present? || input_to_output_currency_parity.present?
      end

      def validate_currency_parities_exchange_rate_up_to_date
        return if output_to_input_currency_parity_exchange_rate.present? ||
                  input_to_output_currency_parity_exchange_rate.present?

        raise CurrencyParities::OutdatedError,
              "Missing updated currency parities exchange rates for conversion: #{input_currency.code} to
               #{output_currency.code} or #{output_currency.code} to #{input_currency.code}"
      end

      def fetch_updated_currency_parity_exchange_rate(currency_parity)
        return nil if currency_parity.blank?

        currency_parity.currency_parity_exchange_rates.updated.order(reference_date: :desc).first
      end

      def compute_asset_price_in_output_currency
        return { price: asset_price.price, currency_parity_exchange_rate: nil } if asset_price_already_in_output_currency?

        if input_to_output_currency_parity_exchange_rate.present?
          { price: input_to_output_currency_parity_price, currency_parity_exchange_rate: input_to_output_currency_parity_exchange_rate }
        else
          { price: output_to_input_currency_parity_price,
            currency_parity_exchange_rate: output_to_input_currency_parity_exchange_rate }
        end
      end

      def output_to_input_currency_parity_price
        asset_price.price.to_d / output_to_input_currency_parity_exchange_rate.exchange_rate.to_d
      end

      def input_to_output_currency_parity_price
        asset_price.price.to_d * input_to_output_currency_parity_exchange_rate.exchange_rate.to_d
      end

      def asset_price_already_in_output_currency?
        asset_price.currency == output_currency
      end
    end
  end
end
