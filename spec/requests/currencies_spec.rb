# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Currencies', type: :request do
  let(:user) { create(:user) }

  let(:valid_headers) do
    user.create_new_auth_token.merge('Accept' => 'application/vnd.investment_portfolio_rebalancer.v1')
  end

  let(:invalid_headers) do
    { 'Accept' => 'application/vnd.investment_portfolio_rebalancer.v1' }
  end

  describe 'GET /index' do
    context 'when user is authenticated' do
      context 'when there are currencies' do
        let!(:currencies) { create_list(:currency, 3) }

        it 'returns a list of currencies' do
          get '/api/currencies', headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body.size).to eq(3)
        end
      end

      context 'when there are no currencies' do
        it 'returns an empty list' do
          get '/api/currencies', headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body.size).to eq(0)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/currencies', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /show' do
    let(:currency) { create(:currency) }

    context 'when the user is authenticated' do
      context 'when the currency exists' do
        it 'returns the currency' do
          get "/api/currencies/#{currency.id}", headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body['id']).to eq(currency.id)
        end
      end

      context 'when the currency does not exist' do
        it 'returns a not found status' do
          get '/api/currencies/-1', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized status' do
        get "/api/currencies/#{currency.id}", headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
