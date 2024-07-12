# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AutomaticRebalanceOptions', type: :request do
  let(:user) { create(:user) }

  let(:valid_headers) do
    user.create_new_auth_token.merge('Accept' => 'application/vnd.investment_portfolio_rebalancer.v1')
  end

  let(:invalid_headers) do
    { 'Accept' => 'application/vnd.investment_portfolio_rebalancer.v1' }
  end

  describe 'GET /index' do
    context 'when user is authenticated' do
      context 'when there has a automatic rebalance option' do
        let(:investment_portfolio) { create(:investment_portfolio, user:) }
        let!(:automatic_rebalance_option) { create(:automatic_rebalance_option, investment_portfolio:) }

        it 'returns a success status' do
          get '/api/automatic_rebalance_options', headers: valid_headers, as: :json

          expect(response).to have_http_status(:success)
          expect(response.body).to include(automatic_rebalance_option.to_json)
        end
      end

      context 'when there has no automatic rebalance option' do
        it 'returns a success status' do
          get '/api/automatic_rebalance_options', headers: valid_headers, as: :json

          expect(response).to have_http_status(:success)
          expect(response.body).to eq('[]')
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/automatic_rebalance_options', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /show' do
    context 'when user is authenticated' do
      context 'when automatic rebalance option exists' do
        let(:investment_portfolio) { create(:investment_portfolio, user:) }
        let!(:automatic_rebalance_option) { create(:automatic_rebalance_option, investment_portfolio:) }

        it 'returns a success status' do
          get "/api/automatic_rebalance_options/#{automatic_rebalance_option.id}", headers: valid_headers, as: :json

          expect(response).to have_http_status(:success)
          expect(response.body).to include(automatic_rebalance_option.to_json)
        end
      end

      context 'when automatic rebalance option does not exist' do
        it 'returns a not found status' do
          get '/api/automatic_rebalance_options/0', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
          expect(response.parsed_body['error']).to eq('Automatic rebalance option not found')
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/automatic_rebalance_options/0', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /create' do
    context 'when user is authenticated' do
      let(:investment_portfolio) { create(:investment_portfolio, user:) }

      context 'when the request is valid' do
        let(:valid_params) do
          {
            automatic_rebalance_option: {
              kind: 'recurrence',
              start_date: Time.zone.now,
              recurrence_days: 30,
              investment_portfolio_id: investment_portfolio.id
            }
          }
        end

        it 'creates a new automatic rebalance option' do
          post '/api/automatic_rebalance_options', params: valid_params, headers: valid_headers, as: :json

          expect(response).to have_http_status(:created)
          expect(AutomaticRebalanceOption.count).to eq(1)
        end
      end

      context 'when the request is invalid' do
        context 'when the investment portfolio does not exist' do
          let(:invalid_params) do
            {
              automatic_rebalance_option: {
                kind: 'random',
                start_date: Time.zone.now,
                recurrence_days: 30
              }
            }
          end

          it 'returns an unprocessable entity status' do
            post '/api/automatic_rebalance_options', params: invalid_params, headers: valid_headers, as: :json

            expect(response).to have_http_status(:not_found)
            expect(response.parsed_body['error']).to eq('Investment portfolio not found')
          end
        end

        context 'when the investment portfolio belongs to another user' do
          let(:investment_portfolio) { create(:investment_portfolio) }
          let(:invalid_params) do
            {
              automatic_rebalance_option: {
                kind: 'recurrence',
                start_date: Time.zone.now,
                recurrence_days: 30,
                investment_portfolio_id: investment_portfolio.id
              }
            }
          end

          it 'returns an unprocessable entity status' do
            post '/api/automatic_rebalance_options', params: invalid_params, headers: valid_headers, as: :json

            expect(response).to have_http_status(:not_found)
            expect(response.parsed_body['error']).to eq('Investment portfolio not found')
          end
        end

        context 'when the user has a previous automatic rebalance option' do
          let!(:automatic_rebalance_option) { create(:automatic_rebalance_option, investment_portfolio:) }
          let(:valid_params) do
            {
              automatic_rebalance_option: {
                kind: 'recurrence',
                start_date: Time.zone.now,
                recurrence_days: 30,
                investment_portfolio_id: investment_portfolio.id
              }
            }
          end

          it 'does not allow multiple automatic rebalance_options' do
            post '/api/automatic_rebalance_options', params: valid_params, headers: valid_headers, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
            expect(AutomaticRebalanceOption.count).to eq(1)
            expect(response.parsed_body).to eq({ 'investment_portfolio_id' => ['has already been taken'] })
          end
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        post '/api/automatic_rebalance_options', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /destroy' do
    context 'when user is authenticated' do
      context 'when the automatic rebalance option can be deleted' do
        let(:investment_portfolio) { create(:investment_portfolio, user:) }
        let!(:automatic_rebalance_option) { create(:automatic_rebalance_option, investment_portfolio:) }

        before do
          create(:rebalance_order, investment_portfolio:, created_by_system: true, status: 'pending', scheduled_at: 1.day.from_now)
        end

        it 'deletes the automatic rebalance option and removes all pending rebalance orders generated by system' do
          delete "/api/automatic_rebalance_options/#{automatic_rebalance_option.id}", headers: valid_headers, as: :json

          expect(response).to have_http_status(:no_content)
          expect(AutomaticRebalanceOption.count).to eq(0)
          expect(RebalanceOrder.count).to eq(0)
        end
      end

      context 'when the automatic rebalance option cannot be deleted' do
        context 'when the automatic rebalance option does not exist' do
          it 'returns a not found status' do
            delete '/api/automatic_rebalance_options/0', headers: valid_headers, as: :json

            expect(response).to have_http_status(:not_found)
            expect(response.parsed_body['error']).to eq('Automatic rebalance option not found')
          end
        end

        context 'when the automatic rebalance option belongs to another user' do
          let(:investment_portfolio) { create(:investment_portfolio) }
          let!(:automatic_rebalance_option) { create(:automatic_rebalance_option, investment_portfolio:) }

          it 'returns a not found status' do
            delete "/api/automatic_rebalance_options/#{automatic_rebalance_option.id}", headers: valid_headers, as: :json

            expect(response).to have_http_status(:not_found)
            expect(response.parsed_body['error']).to eq('Automatic rebalance option not found')
          end
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        delete '/api/automatic_rebalance_options/0', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
