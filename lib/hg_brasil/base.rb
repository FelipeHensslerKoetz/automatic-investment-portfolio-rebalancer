# frozen_string_literal: true

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
      { 'key' => Rails.application.credentials.hg_brasil[:secret_key] }
    end
  end
end
