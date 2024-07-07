# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CustomerSupportItems', type: :request do
  let(:user) { create(:user) }

  let(:valid_headers) do
    user.create_new_auth_token.merge('Accept' => 'application/vnd.investment_portfolio_rebalancer.v1')
  end

  let(:invalid_headers) do
    { 'Accept' => 'application/vnd.investment_portfolio_rebalancer.v1' }
  end

  describe 'GET /index' do
    context 'when user is authenticated' do
      context 'when there are customer support items' do
        let!(:first_user_customer_support_item) do
          create(:customer_support_item, user:)
        end

        let!(:second_user_customer_support_item) do
          create(:customer_support_item, user:)
        end

        let(:first_user_customer_support_item_serialized) do
          CustomerSupportItemSerializer.new(first_user_customer_support_item).as_json.stringify_keys
        end

        let(:second_user_customer_support_item_serialized) do
          CustomerSupportItemSerializer.new(second_user_customer_support_item).as_json.stringify_keys
        end

        before do
          create(:customer_support_item)
        end

        it 'returns a list containing only the user custom support items' do
          get '/api/customer_support_items', headers: valid_headers

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body.size).to eq(2)
          expect(response.parsed_body).to include(first_user_customer_support_item_serialized, second_user_customer_support_item_serialized)
        end
      end

      context 'when there are no customer support items' do
        it 'returns an empty list of customer support items' do
          get '/api/customer_support_items', headers: valid_headers

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to eq([])
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        get '/api/customer_support_items', headers: invalid_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /show' do
    context 'when user is authenticated' do
      context 'when the customer support item exists' do
        let!(:customer_support_item) { create(:customer_support_item, user:) }

        it 'returns the customer support item' do
          get "/api/customer_support_items/#{customer_support_item.id}", headers: valid_headers

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to eq(CustomerSupportItemSerializer.new(customer_support_item).as_json.stringify_keys)
        end
      end

      context 'when the customer support item does not exist' do
        it 'returns not found status' do
          get '/api/customer_support_items/0', headers: valid_headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        get '/api/customer_support_items/0', headers: invalid_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /create' do
    context 'when user is authenticated' do
      context 'when customer_support_item are valid' do
        let(:customer_support_item_params) do
          {
            customer_support_item: {
              title: 'Title',
              description: 'Description'
            }
          }
        end

        it 'creates a new customer support item' do
          post '/api/customer_support_items', params: customer_support_item_params, headers: valid_headers

          new_customer_support_item = CustomerSupportItem.last

          expect(response).to have_http_status(:created)
          expect(response.parsed_body).to eq(CustomerSupportItemSerializer.new(new_customer_support_item).as_json.stringify_keys)
          expect(CustomerSupportItem.count).to eq(1)
        end
      end

      context 'when customer_support_item are invalid' do
        let(:customer_support_item_params) do
          {
            customer_support_item: {
              title: nil,
              description: nil
            }
          }
        end

        it 'returns unprocessable entity status' do
          post '/api/customer_support_items', params: customer_support_item_params, headers: valid_headers

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        post '/api/customer_support_items', headers: invalid_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /update' do
    context 'when user is authenticated' do
      context 'when the customer support item exists' do
        let(:customer_support_item) { create(:customer_support_item, user:) }

        context 'when customer_support_item are valid' do
          let(:customer_support_item_params) do
            {
              customer_support_item: {
                title: 'New Title',
                description: 'New Description'
              }
            }
          end

          it 'updates the customer support item' do
            patch "/api/customer_support_items/#{customer_support_item.id}", params: customer_support_item_params, headers: valid_headers

            customer_support_item.reload

            expect(response).to have_http_status(:ok)
            expect(response.parsed_body).to eq(CustomerSupportItemSerializer.new(customer_support_item).as_json.stringify_keys)
            expect(customer_support_item.title).to eq('New Title')
            expect(customer_support_item.description).to eq('New Description')
          end
        end

        context 'when customer_support_item are invalid' do
          let(:customer_support_item_params) do
            {
              customer_support_item: {
                title: nil,
                description: nil
              }
            }
          end

          it 'returns unprocessable entity status' do
            patch "/api/customer_support_items/#{customer_support_item.id}", params: customer_support_item_params, headers: valid_headers

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'when the customer support item does not exist' do
        it 'returns not found status' do
          patch '/api/customer_support_items/0', headers: valid_headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        patch '/api/customer_support_items/0', headers: invalid_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /destroy' do
    context 'when user is authenticated' do
      context 'when the customer support item exists' do
        let(:customer_support_item) { create(:customer_support_item, user:) }

        it 'deletes the customer support item' do
          delete "/api/customer_support_items/#{customer_support_item.id}", headers: valid_headers

          expect(response).to have_http_status(:no_content)
          expect(CustomerSupportItem.count).to eq(0)
        end
      end

      context 'when the customer support item does not exist' do
        it 'returns not found status' do
          delete '/api/customer_support_items/0', headers: valid_headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        delete '/api/customer_support_items/0', headers: invalid_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
