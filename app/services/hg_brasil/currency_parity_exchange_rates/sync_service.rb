# frozen_string_literal: true

module HgBrasil
  module CurrencyParityExchangeRates
    class SyncService
      def self.call
        new.call
      end

      def call
        currencies.each do |currency|
          hg_brasil_quotation = fetch_hg_brasil_quotation(currency)
          hg_brasil_quotation.process!
          hg_brasil_quotation.update!(exchange_rate: currency[:exchange_rate], last_sync_at: Time.zone.now, reference_date: Time.zone.now)
          hg_brasil_quotation.up_to_date!
        end
      rescue StandardError => e
        System::Logs::CreatorService.create_log(kind: :error, data: error_message(e))
      end

      private

      def hg_brasil_quote_details
        @hg_brasil_quote_details ||= Integrations::HgBrasil::Currencies.quote_details
      end

      def source
        @source ||= hg_brasil_quote_details.dig('results', 'currencies', 'source')
      end

      def currency_to
        @currency_to ||= Currency.find_by!(code: 'BRL')
      end

      def currencies
        @currencies ||= hg_brasil_quote_details.dig('results', 'currencies').map do |key, value|
          if key == 'source'
            nil
          else
            { code: key, exchange_rate: value['buy'] }
          end
        end.compact_blank
      end

      def partner_resource
        @partner_resource ||= PartnerResource.find_by!(slug: 'hg_brasil_currencies')
      end

      def error_message(error)
        {
          context: self.class.to_s,
          message: error.message,
          backtrace: error.backtrace
        }
      end

      def fetch_hg_brasil_quotation(currency)
        currency_from = Currency.find_by!(code: currency[:code])
        currency_parity = CurrencyParity.find_by!(currency_from:, currency_to:)
        CurrencyParityExchangeRate.find_by!(currency_parity:, partner_resource:)
      end
    end
  end
end
