# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RebalanceOrders', type: :request do
  let(:user) { create(:user) }

  let(:valid_headers) do
    user.create_new_auth_token.merge('Accept' => 'application/vnd.investment_portfolio_rebalancer.v1')
  end

  let(:invalid_headers) do
    { 'Accept' => 'application/vnd.investment_portfolio_rebalancer.v1' }
  end

  describe 'GET /index' do
    context 'when user is authenticated' do
      context 'when there are rebalance orders' do
        let(:user) { create(:user) }
        let(:investment_portfolio) { create(:investment_portfolio, user:) }
        let!(:rebalance_orders) { create(:rebalance_order, :default, investment_portfolio:, user:) }

        it 'returns a list of rebalance orders' do
          get '/api/rebalance_orders', headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body.size).to eq(1)
        end
      end

      context 'when there are no rebalance orders' do
        it 'returns an empty list' do
          get '/api/rebalance_orders', headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body.size).to eq(0)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/rebalance_orders', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /show' do
    context 'when user is authenticated' do
      context 'when the rebalance order exists' do
        context 'when the rebalance order belongs to the user' do
          let(:user) { create(:user) }
          let(:investment_portfolio) { create(:investment_portfolio, user:) }
          let(:rebalance_order) { create(:rebalance_order, :default, investment_portfolio:, user:) }

          it 'returns the rebalance order' do
            get "/api/rebalance_orders/#{rebalance_order.id}", headers: valid_headers, as: :json

            expect(response).to be_successful
            expect(response.parsed_body['id']).to eq(rebalance_order.id)
          end
        end

        context 'when the rebalance order does not belong to the user' do
          let(:user) { create(:user) }
          let(:another_user) { create(:user) }
          let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }
          let(:rebalance_order) { create(:rebalance_order, :default, investment_portfolio:, user: another_user) }

          it 'returns a not found status' do
            get "/api/rebalance_orders/#{rebalance_order.id}", headers: valid_headers, as: :json

            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context 'when the rebalance order does not exist' do
        it 'returns a not found status' do
          get '/api/rebalance_orders/1', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/rebalance_orders/1', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /create' do
    context 'when user is authenticated' do
      context 'when params are valid' do
        let(:investment_portfolio) { create(:investment_portfolio, user:) }

        context 'when kind is default' do
          let(:rebalance_order_params) do
            {
              rebalance_order: {
                investment_portfolio_id: investment_portfolio.id,
                kind: 'default',
                amount: 0
              }
            }
          end

          it 'creates a rebalance order' do
            post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

            created_rebalance_order = RebalanceOrder.last

            expect(response).to be_successful
            expect(JSON.parse(response.body)).to eq(JSON.parse(RebalanceOrderSerializer.new(created_rebalance_order).to_json))
            expect(RebalanceOrder.count).to eq(1)
            expect(created_rebalance_order.attributes).to include(
             'kind' => 'default',
             'amount' => 0,
             'investment_portfolio_id' => investment_portfolio.id,
             'scheduled_at' => Time.zone.today,
             'user_id' => user.id,
             'created_by_system' => false) 
          end
        end

        context 'when kind is deposit' do
          let(:rebalance_order_params) do
            {
              rebalance_order: {
                investment_portfolio_id: investment_portfolio.id,
                kind: 'default',
                amount: 100.0
              }
            }
          end

          it 'creates a rebalance order' do
            post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

            created_rebalance_order = RebalanceOrder.last

            expect(response).to be_successful
            expect(JSON.parse(response.body)).to eq(JSON.parse(RebalanceOrderSerializer.new(created_rebalance_order).to_json))
            expect(RebalanceOrder.count).to eq(1)
            expect(created_rebalance_order.attributes).to include(
             'kind' => 'default',
             'amount' => 100,
             'investment_portfolio_id' => investment_portfolio.id,
             'scheduled_at' => Time.zone.today,
             'user_id' => user.id,
             'created_by_system' => false) 
          end
        end

        context 'when kind is withdraw' do
          let(:rebalance_order_params) do
            {
              rebalance_order: {
                investment_portfolio_id: investment_portfolio.id,
                kind: 'default',
                amount: -100.0,
                scheduled_at: Time.zone.today + 1.day
              }
            }
          end

          it 'creates a rebalance order' do
            post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

            created_rebalance_order = RebalanceOrder.last

            expect(response).to be_successful
            expect(JSON.parse(response.body)).to eq(JSON.parse(RebalanceOrderSerializer.new(created_rebalance_order).to_json))
            expect(RebalanceOrder.count).to eq(1)
            expect(created_rebalance_order.attributes).to include(
             'kind' => 'default',
             'amount' => -100,
             'investment_portfolio_id' => investment_portfolio.id,
             'scheduled_at' => Time.zone.today + 1.day,
             'user_id' => user.id,
             'created_by_system' => false)
          end
        end
      end

      context 'when params are invalid' do
        context 'when investment_portfolio_id is missing' do
          let(:rebalance_order_params) do
            {
              rebalance_order: {
                kind: 'default',
                amount: 0
              }
            }
          end

          it 'returns an unprocessable entity status' do
            post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when investment_portfolio_id is invalid' do
          context 'when investment_portfolio does not belong to the user' do
            let(:another_user) { create(:user) }
            let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }

            let(:rebalance_order_params) do
              {
                rebalance_order: {
                  investment_portfolio_id: investment_portfolio.id,
                  kind: 'default',
                  amount: 0
                }
              }
            end

            it 'returns an unprocessable entity status' do
              post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

              expect(response).to have_http_status(:unprocessable_entity)
            end
          end

          context 'when investment_portfolio does not exist' do
            let(:rebalance_order_params) do
              {
                rebalance_order: {
                  investment_portfolio_id: 0,
                  kind: 'default',
                  amount: 0
                }
              }
            end

            it 'returns an unprocessable entity status' do
              post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

              expect(response).to have_http_status(:unprocessable_entity)
            end
          end
        end

        context 'when kind is missing' do
          let(:investment_portfolio) { create(:investment_portfolio, user:) }

          let(:rebalance_order_params) do
            {
              rebalance_order: {
                investment_portfolio_id: investment_portfolio.id,
                amount: 0
              }
            }
          end

          it 'returns an unprocessable entity status' do
            post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when kind is invalid' do
          let(:investment_portfolio) { create(:investment_portfolio, user:) }

          let(:rebalance_order_params) do
            {
              rebalance_order: {
                investment_portfolio_id: investment_portfolio.id,
                kind: 'invalid',
                amount: 0
              }
            }
          end

          it 'returns an unprocessable entity status' do
            post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when amount is invalid' do
          context 'when kind is withdraw' do
            context 'when amount is missing' do
              let(:investment_portfolio) { create(:investment_portfolio, user:) }

              let(:rebalance_order_params) do
                {
                  rebalance_order: {
                    investment_portfolio_id: investment_portfolio.id,
                    kind: 'withdraw'
                  }
                }
              end

              it 'returns an unprocessable entity status' do
                post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

                expect(response).to have_http_status(:unprocessable_entity)
              end
            end

            context 'when amount is not a positive number' do
              let(:investment_portfolio) { create(:investment_portfolio, user:) }

              let(:rebalance_order_params) do
                {
                  rebalance_order: {
                    investment_portfolio_id: investment_portfolio.id,
                    kind: 'withdraw',
                    amount: -100.0
                  }
                }
              end

              it 'returns an unprocessable entity status' do
                post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

                expect(response).to have_http_status(:unprocessable_entity)
              end
            end
          end

          context 'when kind is deposit' do
            context 'when amount is missing' do
              let(:investment_portfolio) { create(:investment_portfolio, user:) }

              let(:rebalance_order_params) do
                {
                  rebalance_order: {
                    investment_portfolio_id: investment_portfolio.id,
                    kind: 'deposit'
                  }
                }
              end

              it 'returns an unprocessable entity status' do
                post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

                expect(response).to have_http_status(:unprocessable_entity)
              end
            end

            context 'when amount is not a positive number' do
              let(:investment_portfolio) { create(:investment_portfolio, user:) }

              let(:rebalance_order_params) do
                {
                  rebalance_order: {
                    investment_portfolio_id: investment_portfolio.id,
                    kind: 'deposit',
                    amount: -100.0
                  }
                }
              end

              it 'returns an unprocessable entity status' do
                post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

                expect(response).to have_http_status(:unprocessable_entity)
              end
            end
          end
        end

        context 'when amount is not a valid number' do
          let(:investment_portfolio) { create(:investment_portfolio, user:) }

          let(:rebalance_order_params) do
            {
              rebalance_order: {
                investment_portfolio_id: investment_portfolio.id,
                kind: 'deposit',
                amount: -100.0
              }
            }
          end

          it 'returns an unprocessable entity status' do
            post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when scheduled_at is not a valid date' do
          context 'when scheduled_at is in the past' do
            let(:investment_portfolio) { create(:investment_portfolio, user:) }

            let(:rebalance_order_params) do
              {
                rebalance_order: {
                  investment_portfolio_id: investment_portfolio.id,
                  kind: 'deposit',
                  amount: 100.0,
                  scheduled_at: Time.zone.today - 1.day
                }
              }
            end

            it 'returns an unprocessable entity status' do
              post '/api/rebalance_orders', headers: valid_headers, params: rebalance_order_params, as: :json

              expect(response).to have_http_status(:unprocessable_entity)
            end
          end
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        post '/api/rebalance_orders', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /update' do
    context 'when user is authenticated' do
      context 'when params are invalid' do
        context 'when kind is invalid' do
          let(:investment_portfolio) { create(:investment_portfolio, user:) }
          let(:rebalance_order) { create(:rebalance_order, :default, investment_portfolio:, user:) }

          let(:rebalance_order_params) do
            {
              rebalance_order: {
                kind: 'invalid'
              }
            }
          end

          it 'returns an unprocessable entity status' do
            put "/api/rebalance_orders/#{rebalance_order.id}", headers: valid_headers, params: rebalance_order_params, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when amount is invalid' do
          let(:investment_portfolio) { create(:investment_portfolio, user:) }

          let(:rebalance_order) { create(:rebalance_order, :default, investment_portfolio:, user:) }

          let(:rebalance_order_params) do
            {
              rebalance_order: {
                kind: 'deposit',
                amount: -100.0
              }
            }
          end

          it 'returns an unprocessable entity status' do
            put "/api/rebalance_orders/#{rebalance_order.id}", headers: valid_headers, params: rebalance_order_params, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when investment_portfolio_id is invalid' do
          context 'when investment_portfolio does not belong to the user' do
            let(:another_user) { create(:user) }
            let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }
            let(:rebalance_order) { create(:rebalance_order, :default, investment_portfolio:, user:) }

            let(:rebalance_order_params) do
              {
                rebalance_order: {
                  investment_portfolio_id: investment_portfolio.id,
                  amount: 500.0
                }
              }
            end

            it 'returns an unprocessable entity status' do
              put "/api/rebalance_orders/#{rebalance_order.id}", headers: valid_headers, params: rebalance_order_params, as: :json

              expect(response).to have_http_status(:unprocessable_entity)
            end
          end

          context 'when investment_portfolio does not exist' do
            let(:investment_portfolio) { create(:investment_portfolio, user:) }
            let(:rebalance_order) { create(:rebalance_order, :default, investment_portfolio:, user:) }

            let(:rebalance_order_params) do
              {
                rebalance_order: {
                  investment_portfolio_id: 0,
                  amount: 500.0
                }
              }
            end

            it 'returns an unprocessable entity status' do
              put "/api/rebalance_orders/#{rebalance_order.id}", headers: valid_headers, params: rebalance_order_params, as: :json

              expect(response).to have_http_status(:unprocessable_entity)
            end
          end
        end

        context 'when record does not exist' do
          it 'returns a not found status' do
            put '/api/rebalance_orders/1', headers: valid_headers, as: :json

            expect(response).to have_http_status(:not_found)
          end
        end

        context 'when record does not belong to the user' do
          let(:another_user) { create(:user) }
          let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }
          let(:rebalance_order) { create(:rebalance_order, :default, investment_portfolio:, user: another_user) }

          let(:rebalance_order_params) do
            {
              rebalance_order: {
                amount: 500.0
              }
            }
          end

          it 'returns a not found status' do
            put "/api/rebalance_orders/#{rebalance_order.id}", headers: valid_headers, params: rebalance_order_params, as: :json

            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context 'when params are valid' do
        context 'when record can be updated' do
          context 'when record status is pending' do
            let(:investment_portfolio) { create(:investment_portfolio, user:) }
            let(:rebalance_order) { create(:rebalance_order, :default, investment_portfolio:, user:) }

            let(:rebalance_order_params) do
              {
                rebalance_order: {
                  amount: 500.0
                }
              }
            end

            it 'updates the rebalance order' do
              put "/api/rebalance_orders/#{rebalance_order.id}", headers: valid_headers, params: rebalance_order_params, as: :json

              expect(response).to be_successful
              expect(response.parsed_body['amount']).to eq('500.0')
            end
          end
        end

        context 'when record cannot be updated' do
          context 'when record status is not pending' do
            let(:investment_portfolio) { create(:investment_portfolio, user:) }
            let(:rebalance_order) { create(:rebalance_order, :default, investment_portfolio:, user:, status: :scheduled) }

            let(:rebalance_order_params) do
              {
                rebalance_order: {
                  amount: 500.0
                }
              }
            end

            it 'returns an unprocessable entity status' do
              put "/api/rebalance_orders/#{rebalance_order.id}", headers: valid_headers, params: rebalance_order_params, as: :json

              expect(response).to have_http_status(:unprocessable_entity)
            end
          end
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        put '/api/rebalance_orders/1', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /destroy' do
    context 'when user is authenticated' do
      context 'when the record belongs to the user' do
        context 'when the record can be deleted' do
          context 'when the record status is pending' do
            let(:investment_portfolio) { create(:investment_portfolio, user:) }
            let(:rebalance_order) { create(:rebalance_order, :default, investment_portfolio:, user:) }

            it 'deletes the rebalance order' do
              delete "/api/rebalance_orders/#{rebalance_order.id}", headers: valid_headers, as: :json

              expect(response).to have_http_status(:no_content)
            end
          end
        end

        context 'when the record cannot be deleted' do
          context 'when the record status is not pending' do
            let(:investment_portfolio) { create(:investment_portfolio, user:) }
            let(:rebalance_order) { create(:rebalance_order, :default, investment_portfolio:, user:, status: :scheduled) }

            it 'returns an unprocessable entity status' do
              delete "/api/rebalance_orders/#{rebalance_order.id}", headers: valid_headers, as: :json

              expect(response).to have_http_status(:unprocessable_entity)
            end
          end
        end
      end

      context 'when the record does not belong to the user' do
        let(:another_user) { create(:user) }
        let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }
        let(:rebalance_order) { create(:rebalance_order, :default, investment_portfolio:, user: another_user) }

        it 'returns a not found status' do
          delete "/api/rebalance_orders/#{rebalance_order.id}", headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the record does not exist' do
        it 'returns a not found status' do
          delete '/api/rebalance_orders/1', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        delete '/api/rebalance_orders/1', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
