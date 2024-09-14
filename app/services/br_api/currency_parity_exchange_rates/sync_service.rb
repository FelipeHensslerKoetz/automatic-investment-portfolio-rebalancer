# frozen_string_literal: true

module BrApi
  module CurrencyParityExchangeRates
    class SyncService # TODO: abstract this service to a base class
      attr_reader :currency_from, :currency_to, :currency_from_code, :currency_to_code

      def initialize(currency_from_code:, currency_to_code:)
        @currency_from_code = currency_from_code
        @currency_to_code = currency_to_code
        @currency_from = Currency.find_by!(code: currency_from_code)
        @currency_to = Currency.find_by!(code: currency_to_code)
      end

      def self.call(currency_from_code:, currency_to_code:)
        new(currency_from_code:, currency_to_code:).call
      end

      def call
        process_currency_parity_exchange_rate!
      rescue StandardError => e
        fail_currency_parity_exchange_rate!(e)
      end

      private

      def process_currency_parity_exchange_rate!
        currency_parity_exchange_rate.process!

        if currency_parity_exchange_rate.update!(currency_parity_exchange_rate_params)
          currency_parity_exchange_rate.update(error_message: nil) if currency_parity_exchange_rate.error_message.present?
          currency_parity_exchange_rate.up_to_date!
          System::Logs::CreatorService.create_log(kind: :info, data: info_message(currency_parity_exchange_rate))
        end
      end

      def fail_currency_parity_exchange_rate!(error)
        error_message = error_message(error)

        if currency_parity_exchange_rate.may_fail?
          currency_parity_exchange_rate.fail!
          currency_parity_exchange_rate.update!(error_message:)
        end

        System::Logs::CreatorService.create_log(kind: :error, data: error_message)
      end

      def info_message
        {
          context: "#{self.class} - currency_from_code: #{currency_from_code} - currency_to_code: #{currency_to_code}",
          message: 'Currency parity exchange rate updated successfully',
          currency_parity_exchange_rate_id: currency_parity_exchange_rate.id
        }
      end

      def error_message(error)
        {
          context: "#{self.class} - currency_from_code: #{currency_from_code} - currency_to_code: #{currency_to_code}",
          message: error.message,
          backtrace: error.backtrace
        }
      end

      def partner_resource
        @partner_resource ||= PartnerResource.find_by!(slug: 'br_api_currencies')
      end

      def currency_parity
        @currency_parity ||= CurrencyParity.find_by!(
          currency_from:,
          currency_to:
        )
      end

      def currency_parity_exchange_rate
        @currency_parity_exchange_rate ||= CurrencyParityExchangeRate.find_by!(
          partner_resource:,
          currency_parity:
        )
      end

      def currency_parity_exchange_rate_params
        {
          exchange_rate: currency_parity_exchange_rate_details[:exchange_rate],
          reference_date: currency_parity_exchange_rate_details[:reference_date],
          last_sync_at: Time.zone.now
        }
      end

      def currency_parity_exchange_rate_details
        @currency_parity_exchange_rate_details ||= Integrations::BrApi::Currencies.currencies_details(from_to_iso_code:).detect do |currency_parities_details|
          currency_parities_details[:currency_from_code] == currency_from.code &&
            currency_parities_details[:currency_to_code] == currency_to.code
        end
      end

      def from_to_iso_code
        "#{currency_from.code}-#{currency_to.code}"
      end
    end
  end
end
