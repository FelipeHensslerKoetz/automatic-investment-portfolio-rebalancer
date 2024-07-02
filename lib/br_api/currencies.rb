# frozen_string_literal: true

module BrApi
  class Currencies < BrApi::Base
    attr_reader :from_to_iso_code

    def self.currencies_details(from_to_iso_code:)
      new(from_to_iso_code:).currencies_details
    end

    def initialize(from_to_iso_code:)
      super()
      @from_to_iso_code = from_to_iso_code
    end

    def currencies_details
      response ||= get(url: '/currency', params: { currency: from_to_iso_code })

      return nil if request_error?(response)

      response['currency'].map do |currency|
        {
          currency_from_code: currency['fromCurrency'],
          currency_to_code: currency['toCurrency'],
          exchange_rate: currency['bidPrice'],
          reference_date: currency['updatedAtDate']
        }
      end
    end

    private

    def base_url
      Rails.application.credentials.br_api[:base_url_v2]
    end

    def request_error?(response)
      invalid_response?(response) || all_currency_parities_blank?(response)
    end

    def invalid_response?(response)
      response&.dig('currency').blank?
    end

    def all_currency_parities_blank?(response)
      response['currency'].all?(&:blank?)
    end
  end
end
