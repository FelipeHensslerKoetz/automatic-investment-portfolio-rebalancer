# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CustomerSupportItemMessages', type: :request do
  let(:user) { create(:user) }

  let(:valid_headers) do
    user.create_new_auth_token.merge('Accept' => 'application/vnd.investment_portfolio_rebalancer.v1')
  end

  let(:invalid_headers) do
    { 'Accept' => 'application/vnd.investment_portfolio_rebalancer.v1' }
  end

  describe 'GET /customer_support_item_messages' do
    context 'when user is authenticated' do
      context 'when the user has customer support item messages' do
        let!(:first_customer_support_item_message) { create(:customer_support_item_message, user:) }
        let!(:second_customer_support_item_message) { create(:customer_support_item_message, user:) }

        let(:first_customer_support_item_message_serialized) do
          CustomerSupportItemMessageSerializer.new(first_customer_support_item_message).as_json.deep_stringify_keys
        end

        let(:second_customer_support_item_message_serialized) do
          CustomerSupportItemMessageSerializer.new(second_customer_support_item_message).as_json.deep_stringify_keys
        end

        it 'returns the customer support item messages' do
          get '/api/customer_support_item_messages', headers: valid_headers

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to include(first_customer_support_item_message_serialized,
                                                  second_customer_support_item_message_serialized)
        end
      end

      context 'when the user does not have customer support item messages' do
        it 'returns an empty array' do
          get '/api/customer_support_item_messages', headers: valid_headers

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to eq([])
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        get '/api/customer_support_item_messages', headers: invalid_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /customer_support_item_messages/:id' do
    context 'when user is authenticated' do
      context 'when the customer support item message exists' do
        let!(:customer_support_item_message) { create(:customer_support_item_message, user:) }

        let(:customer_support_item_message_serialized) do
          CustomerSupportItemMessageSerializer.new(customer_support_item_message).as_json.deep_stringify_keys
        end

        it 'returns the customer support item message' do
          get "/api/customer_support_item_messages/#{customer_support_item_message.id}", headers: valid_headers

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to eq(customer_support_item_message_serialized)
        end
      end

      context 'when the customer support item message does not exist' do
        it 'returns not found status' do
          get '/api/customer_support_item_messages/1', headers: valid_headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        get '/api/customer_support_item_messages/1', headers: invalid_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /customer_support_item_messages' do
    context 'when user is authenticated' do
      context 'when the user is not a admin' do
        context 'when the customer_support item id belongs to the user' do
          let!(:customer_support_item) { create(:customer_support_item, user:) }

          let(:customer_support_item_message_params) do
            {
              customer_support_item_message: {
                customer_support_item_id: customer_support_item.id,
                message: 'This is a message'
              }
            }
          end

          it 'creates a new customer support item message' do
            post '/api/customer_support_item_messages', headers: valid_headers, params: customer_support_item_message_params

            new_customer_support_item_message = CustomerSupportItemMessage.last

            expect(response).to have_http_status(:created)
            expect(new_customer_support_item_message).to have_attributes(
              user_id: user.id,
              customer_support_item_id: customer_support_item.id,
              message: 'This is a message'
            )

            expect(CustomerSupportItemMessage.count).to eq(1)
            expect(response.parsed_body).to eq(CustomerSupportItemMessageSerializer.new(
              new_customer_support_item_message
            ).as_json.deep_stringify_keys)
          end
        end

        context 'when the customer_support item id does not belong to the user' do
          let!(:non_admin_user) { create(:user) }
          let!(:customer_support_item) { create(:customer_support_item, user: non_admin_user) }

          let(:customer_support_item_message_params) do
            {
              customer_support_item_message: {
                customer_support_item_id: customer_support_item.id,
                message: 'This is a message'
              }
            }
          end

          it 'returns not found status' do
            post '/api/customer_support_item_messages', headers: valid_headers, params: customer_support_item_message_params

            expect(response).to have_http_status(:not_found)
          end
        end

        context 'when the customer_support item id does not exist' do
          let(:customer_support_item_message_params) do
            {
              customer_support_item_message: {
                customer_support_item_id: 1,
                message: 'This is a message'
              }
            }
          end

          it 'returns not found status' do
            post '/api/customer_support_item_messages', headers: valid_headers, params: customer_support_item_message_params

            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context 'when the user is a admin' do
        let!(:non_admin_user) { create(:user) }
        let!(:customer_support_item) { create(:customer_support_item, user: non_admin_user) }

        before do
          user.update(admin: true)
        end

        let(:customer_support_item_message_params) do
          {
            customer_support_item_message: {
              customer_support_item_id: customer_support_item.id,
              message: 'This is a message'
            }
          }
        end

        it 'creates a new customer support item message' do
          post '/api/customer_support_item_messages', headers: valid_headers, params: customer_support_item_message_params

          new_customer_support_item_message = CustomerSupportItemMessage.last

          expect(response).to have_http_status(:created)
          expect(new_customer_support_item_message).to have_attributes(
            user_id: user.id,
            customer_support_item_id: customer_support_item.id,
            message: 'This is a message'
          )

          expect(CustomerSupportItemMessage.count).to eq(1)
          expect(response.parsed_body).to eq(CustomerSupportItemMessageSerializer.new(
            new_customer_support_item_message
          ).as_json.deep_stringify_keys)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        post '/api/customer_support_item_messages', headers: invalid_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
