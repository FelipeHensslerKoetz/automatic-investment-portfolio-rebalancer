# frozen_string_literal: true

module HttpRequest
  class Base
    def get(url: nil, params: {}, headers: {})
      response = Faraday.get(final_url(url), final_params(params),
                             final_headers(headers))

      create_http_request_log(response)

      JSON.parse(response.body)
    rescue Faraday::Error => e
      create_http_request_error_log(final_url(url), final_params(params), final_headers(headers), error_details(e))
      nil
    end

    private

    def final_params(params)
      base_params.merge(params)
    end

    def final_headers(headers)
      base_headers.merge(headers)
    end

    def final_url(url)
      "#{base_url}#{url}"
    end

    def base_url
      raise NotImplementedError
    end

    def base_params
      raise NotImplementedError
    end

    def base_headers
      raise NotImplementedError
    end

    def error_details(faraday_error)
      {
        error: faraday_error.message,
        backtrace: faraday_error.backtrace
      }
    end

    def create_http_request_log(faraday_response)
      System::Logs::CreatorService.create_log(kind: :info, data: {
                                        request_url: faraday_response.env.url.to_s,
                                        request_method: faraday_response.env.method.to_s.upcase,
                                        request_headers: faraday_response.env.request_headers,
                                        request_query_params: faraday_response.env.params,
                                        response_body: JSON.parse(faraday_response.body),
                                        response_status_code: faraday_response.status,
                                        response_headers: faraday_response.headers
                                      })
    end

    def create_http_request_error_log(url, params, headers, error)
      System::Logs::CreatorService.create_log(kind: :error, data: {
                                        request_url: url,
                                        request_method: 'GET',
                                        request_headers: headers,
                                        request_query_params: params,
                                        response_errors: error
                                      })
    end
  end
end
