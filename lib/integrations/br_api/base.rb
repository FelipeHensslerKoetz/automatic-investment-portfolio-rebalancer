# frozen_string_literal: true

module Integrations
  module BrApi
    class Base < HttpRequest::Base
      private

      def base_url
        Rails.application.credentials.br_api[:base_url]
      end

      def base_headers
        {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{br_api_secret_key}"
        }
      end

      def base_params
        {}
      end

      def br_api_secret_key
        Rails.application.credentials.br_api[:secret_key]
      end
    end
  end
end
