# frozen_string_literal: true

module Integrations
  module HgBrasil
    class Base < HttpRequest::Base
      private

      def base_url
        Rails.application.credentials.hg_brasil[:base_url]
      end

      def base_headers
        {
          'Content-Type' => 'application/json'
        }
      end

      def base_params
        { 'key' => secret_key }
      end

      def secret_key
        if Rails.env.production? 
          Rails.application.credentials.hg_brasil[:production_secret_key]
        else
          Rails.application.credentials.hg_brasil[:secret_key]
        end
      end
    end
  end
end
