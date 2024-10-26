# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'InvestmentPortfolioRebalanceNotificationOptions', type: :request do
  let(:user) { create(:user) }

  let(:valid_headers) do
    user.create_new_auth_token.merge('Accept' => 'application/vnd.investment_portfolio_rebalancer.v1')
  end

  let(:invalid_headers) do
    { 'Accept' => 'application/vnd.investment_portfolio_rebalancer.v1' }
  end

  describe 'GET /index' do
    context 'when user is authenticated' do
      context 'when there are investment portfolio rebalance notification options' do
        let(:investment_portfolio) { create(:investment_portfolio, user:) }
        let!(:investment_portfolio_rebalance_notification_options) do
          create_list(:investment_portfolio_rebalance_notification_option, 3, :webhook, investment_portfolio:)
        end

        it 'returns a list of investment portfolio rebalance notification options' do
          get '/api/investment_portfolio_rebalance_notification_options', headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body.size).to eq(3)
          expect(response.parsed_body).to match_array(investment_portfolio_rebalance_notification_options.as_json)
        end
      end

      context 'when there are no investment portfolio rebalance notification options' do
        it 'returns an empty list' do
          get '/api/investment_portfolio_rebalance_notification_options', headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body.size).to eq(0)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/investment_portfolio_rebalance_notification_options', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /show' do
    context 'when user is authenticated' do
      context 'when the investment portfolio rebalance notification option exists' do
        context 'when the investment portfolio belongs to the user' do
          let(:investment_portfolio) { create(:investment_portfolio, user:) }
          let(:investment_portfolio_rebalance_notification_option) do
            create(:investment_portfolio_rebalance_notification_option, :webhook, investment_portfolio:)
          end

          it 'returns the investment portfolio rebalance notification option' do
            get "/api/investment_portfolio_rebalance_notification_options/#{investment_portfolio_rebalance_notification_option.id}",
                headers: valid_headers, as: :json

            expect(response).to be_successful
            expect(response.parsed_body).to eq(investment_portfolio_rebalance_notification_option.as_json)
          end
        end

        context 'when the investment portfolio does not belong to the user' do
          let(:another_user) { create(:user) }
          let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }
          let(:investment_portfolio_rebalance_notification_option) do
            create(:investment_portfolio_rebalance_notification_option, :webhook, investment_portfolio:)
          end

          it 'returns a not found status' do
            get "/api/investment_portfolio_rebalance_notification_options/#{investment_portfolio_rebalance_notification_option.id}",
                headers: valid_headers, as: :json

            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context 'when the investment portfolio rebalance notification option does not exist' do
        it 'returns a not found status' do
          get '/api/investment_portfolio_rebalance_notification_options/1', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/investment_portfolio_rebalance_notification_options/1', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /create' do
    context 'when user is authenticated' do
      context 'when the investment portfolio rebalance notification option payload is valid' do
        context 'when the investment portfolio belongs to the user' do
          context 'when creating a webhook investment portfolio rebalance notification option' do
            let(:investment_portfolio) { create(:investment_portfolio, user:) }
            let(:investment_portfolio_rebalance_notification_option_params) do
              {
                investment_portfolio_rebalance_notification_option: {
                  investment_portfolio_id: investment_portfolio.id,
                  kind: 'webhook',
                  name: 'Name',
                  url: 'http://localhost:3000',
                  header: { 'Content-Type' => 'application/json' }.to_json
                }
              }
            end

            it 'creates a investment portfolio rebalance notification option' do
              post '/api/investment_portfolio_rebalance_notification_options',
                   headers: valid_headers, params: investment_portfolio_rebalance_notification_option_params, as: :json

              expect(response).to have_http_status(:created)
              expect(response.parsed_body['investment_portfolio_id']).to eq(investment_portfolio.id)
              expect(response.parsed_body['kind']).to eq('webhook')
              expect(response.parsed_body['name']).to eq('Name')
              expect(response.parsed_body['url']).to eq('http://localhost:3000')
              expect(response.parsed_body['header']).to eq('Content-Type' => 'application/json')
              expect(InvestmentPortfolioRebalanceNotificationOption.count).to eq(1)
            end
          end

          context 'when creating a email investment portfolio rebalance notification option' do
            let(:investment_portfolio) { create(:investment_portfolio, user:) }
            let(:investment_portfolio_rebalance_notification_option_params) do
              {
                investment_portfolio_rebalance_notification_option: {
                  investment_portfolio_id: investment_portfolio.id,
                  kind: 'email',
                  name: 'Name',
                  email: 'my_email@gmail.com'
                }
              }
            end

            it 'creates a investment portfolio rebalance notification option' do
              post '/api/investment_portfolio_rebalance_notification_options',
                   headers: valid_headers, params: investment_portfolio_rebalance_notification_option_params, as: :json

              expect(response).to have_http_status(:created)
              expect(response.parsed_body['investment_portfolio_id']).to eq(investment_portfolio.id)
              expect(response.parsed_body['kind']).to eq('email')
              expect(response.parsed_body['name']).to eq('Name')
              expect(response.parsed_body['email']).to eq('my_email@gmail.com')
              expect(InvestmentPortfolioRebalanceNotificationOption.count).to eq(1)
            end
          end
        end

        context 'when the investment portfolio does not belong to the user' do
          let(:another_user) { create(:user) }
          let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }
          let(:investment_portfolio_rebalance_notification_option_params) do
            {
              investment_portfolio_rebalance_notification_option: {
                investment_portfolio_id: investment_portfolio.id,
                kind: 'webhook',
                name: 'Name',
                url: 'http://localhost:3000',
                header: { 'Content-Type' => 'application/json' }
              }
            }
          end

          it 'returns unprocessable entity status' do
            post '/api/investment_portfolio_rebalance_notification_options',
                 headers: valid_headers, params: investment_portfolio_rebalance_notification_option_params, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
            expect(InvestmentPortfolioRebalanceNotificationOption.count).to be_zero
          end
        end
      end

      context 'when the investment portfolio rebalance notification option is invalid' do
        context 'when the investment portfolio does not exist' do
          let(:investment_portfolio_rebalance_notification_option_params) do
            {
              investment_portfolio_rebalance_notification_option: {
                investment_portfolio_id: 0,
                kind: 'webhook',
                name: 'Name',
                url: 'http://localhost:3000',
                header: { 'Content-Type' => 'application/json' }.to_json
              }
            }
          end

          it 'returns unprocessable_entity' do
            post '/api/investment_portfolio_rebalance_notification_options',
                 headers: valid_headers, params: investment_portfolio_rebalance_notification_option_params, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body).to eq(
              {
                'investment_portfolio' => ['must exist']
              }
            )
            expect(InvestmentPortfolioRebalanceNotificationOption.count).to be_zero
          end
        end

        context 'whe the investment portfolio belongs to another user' do
          let(:another_user) { create(:user) }
          let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }
          let(:investment_portfolio_rebalance_notification_option_params) do
            {
              investment_portfolio_rebalance_notification_option: {
                investment_portfolio_id: investment_portfolio.id,
                kind: 'webhook',
                name: 'Name',
                url: 'http://localhost:3000',
                header: { 'Content-Type' => 'application/json' }.to_json
              }
            }
          end

          it 'returns unprocessable_entity' do
            post '/api/investment_portfolio_rebalance_notification_options',
                 headers: valid_headers, params: investment_portfolio_rebalance_notification_option_params, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body).to eq(
              {
                'investment_portfolio' => ['must exist']
              }
            )
            expect(InvestmentPortfolioRebalanceNotificationOption.count).to be_zero
          end
        end

        context 'when payload has invalid parameters' do
          let(:investment_portfolio_rebalance_notification_option_params) do
            {
              investment_portfolio_rebalance_notification_option: {
                investment_portfolio_id: nil,
                kind: nil,
                name: nil,
                url: nil,
                header: nil
              }
            }
          end

          it 'returns an unprocessable_entity status' do
            post '/api/investment_portfolio_rebalance_notification_options',
                 headers: valid_headers, params: investment_portfolio_rebalance_notification_option_params, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body).to eq(
              {
                'investment_portfolio' => ['must exist'], 'name' => ["can't be blank"], 'kind' => ["can't be blank",
                                                                                                   'is not included in the list']
              }
            )
            expect(InvestmentPortfolioRebalanceNotificationOption.count).to be_zero
          end
        end

        context 'when payload has invalid format' do
          let(:investment_portfolio_rebalance_notification_option_params) { {} }

          it 'returns an bad_request status' do
            post '/api/investment_portfolio_rebalance_notification_options',
                 headers: valid_headers, params: investment_portfolio_rebalance_notification_option_params, as: :json

            expect(response).to have_http_status(:bad_request)
            expect(response.parsed_body).to eq(
              { 'error' => 'param is missing or the value is empty: investment_portfolio_rebalance_notification_option' }
            )
            expect(InvestmentPortfolioRebalanceNotificationOption.count).to be_zero
          end
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        post '/api/investment_portfolio_rebalance_notification_options', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /update' do
    context 'when user is authenticated' do
      context 'when the investment portfolio rebalance notification option exists' do
        context 'when the investment portfolio belongs to the user' do
          context 'when the params are correct' do
            context 'when updating a webhook investment portfolio rebalance notification option' do
              let(:investment_portfolio) { create(:investment_portfolio, user:) }
              let(:investment_portfolio_rebalance_notification_option) do
                create(:investment_portfolio_rebalance_notification_option, :webhook, investment_portfolio:)
              end
              let(:investment_portfolio_rebalance_notification_option_params) do
                {
                  investment_portfolio_rebalance_notification_option: {
                    name: 'New Name',
                    url: 'http://localhost:3000',
                    header: { 'Content-Type' => 'application/json' }.to_json
                  }
                }
              end

              it 'updates the investment portfolio rebalance notification option' do
                patch "/api/investment_portfolio_rebalance_notification_options/#{investment_portfolio_rebalance_notification_option.id}",
                      headers: valid_headers, params: investment_portfolio_rebalance_notification_option_params, as: :json

                investment_portfolio_rebalance_notification_option.reload

                expect(response).to have_http_status(:ok)
                expect(response.parsed_body['name']).to eq('New Name')
                expect(response.parsed_body['url']).to eq('http://localhost:3000')
                expect(response.parsed_body['header']).to eq('Content-Type' => 'application/json')
              end
            end

            context 'when updating a email investment portfolio rebalance notification option' do
              let(:investment_portfolio) { create(:investment_portfolio, user:) }
              let(:investment_portfolio_rebalance_notification_option) do
                create(:investment_portfolio_rebalance_notification_option, :email, investment_portfolio:)
              end
              let(:investment_portfolio_rebalance_notification_option_params) do
                {
                  investment_portfolio_rebalance_notification_option: {
                    name: 'New Name',
                    email: 'new_email@gmail.com'
                  }
                }
              end

              it 'updates the investment portfolio rebalance notification option' do
                patch "/api/investment_portfolio_rebalance_notification_options/#{investment_portfolio_rebalance_notification_option.id}",
                      headers: valid_headers, params: investment_portfolio_rebalance_notification_option_params, as: :json

                investment_portfolio_rebalance_notification_option.reload

                expect(response).to have_http_status(:ok)
                expect(response.parsed_body['name']).to eq('New Name')
                expect(response.parsed_body['email']).to eq('new_email@gmail.com')
              end
            end

            context 'when converting a webhook investment portfolio rebalance notification option to email' do
              let(:investment_portfolio) { create(:investment_portfolio, user:) }
              let(:investment_portfolio_rebalance_notification_option) do
                create(:investment_portfolio_rebalance_notification_option, :webhook, investment_portfolio:)
              end

              let(:investment_portfolio_rebalance_notification_option_params) do
                {
                  investment_portfolio_rebalance_notification_option: {
                    kind: 'email',
                    email: 'my_email@gmail.com'
                  }
                }
              end

              it 'converts the investment portfolio rebalance notification option' do
                patch "/api/investment_portfolio_rebalance_notification_options/#{investment_portfolio_rebalance_notification_option.id}",
                      headers: valid_headers, params: investment_portfolio_rebalance_notification_option_params, as: :json

                investment_portfolio_rebalance_notification_option.reload

                expect(response).to have_http_status(:ok)
                expect(response.parsed_body['kind']).to eq('email')
                expect(response.parsed_body['email']).to eq('my_email@gmail.com')
              end
            end

            context 'when converting a email investment portfolio rebalance notification option to webhook' do
              let(:investment_portfolio) { create(:investment_portfolio, user:) }
              let(:investment_portfolio_rebalance_notification_option) do
                create(:investment_portfolio_rebalance_notification_option, :email, investment_portfolio:)
              end

              let(:investment_portfolio_rebalance_notification_option_params) do
                {
                  investment_portfolio_rebalance_notification_option: {
                    kind: 'webhook',
                    name: 'Name',
                    url: 'http://localhost:3000',
                    header: { 'Content-Type' => 'application/json' }.to_json
                  }
                }
              end

              it 'converts the investment portfolio rebalance notification option' do
                patch "/api/investment_portfolio_rebalance_notification_options/#{investment_portfolio_rebalance_notification_option.id}",
                      headers: valid_headers, params: investment_portfolio_rebalance_notification_option_params, as: :json

                investment_portfolio_rebalance_notification_option.reload

                expect(response).to have_http_status(:ok)
                expect(response.parsed_body['kind']).to eq('webhook')
                expect(response.parsed_body['name']).to eq('Name')
                expect(response.parsed_body['url']).to eq('http://localhost:3000')
                expect(response.parsed_body['header']).to eq('Content-Type' => 'application/json')
              end
            end
          end

          context 'when the params are incorrect' do
            let(:investment_portfolio) { create(:investment_portfolio, user:) }
            let(:investment_portfolio_rebalance_notification_option) do
              create(:investment_portfolio_rebalance_notification_option, :webhook, investment_portfolio:)
            end
            let(:investment_portfolio_rebalance_notification_option_params) do
              {
                investment_portfolio_rebalance_notification_option: {
                  name: nil,
                  url: nil,
                  header: '123'
                }
              }
            end

            it 'ignore the empty fields and returns an unprocessable_entity status' do
              patch "/api/investment_portfolio_rebalance_notification_options/#{investment_portfolio_rebalance_notification_option.id}",
                    headers: valid_headers, params: investment_portfolio_rebalance_notification_option_params, as: :json

              expect(response).to have_http_status(:unprocessable_entity)
              expect(response.parsed_body).to eq(
                {
                  "header" => ["must be an object"],
                }
              )
            end
          end
        end

        context 'when the investment portfolio does not belong to the user' do
          let(:another_user) { create(:user) }
          let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }
          let(:investment_portfolio_rebalance_notification_option) do
            create(:investment_portfolio_rebalance_notification_option, :webhook, investment_portfolio:)
          end

          it 'returns a not found status' do
            patch "/api/investment_portfolio_rebalance_notification_options/#{investment_portfolio_rebalance_notification_option.id}",
                  headers: valid_headers, as: :json

            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context 'when the investment portfolio rebalance notification option does not exist' do
        it 'returns a not found status' do
          patch '/api/investment_portfolio_rebalance_notification_options/1', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        patch '/api/investment_portfolio_rebalance_notification_options/1', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /destroy' do
    context 'when user is authenticated' do
      context 'when the investment portfolio rebalance notification option exists' do
        context 'when the investment portfolio belongs to the user' do
          let(:investment_portfolio) { create(:investment_portfolio, user:) }
          let(:investment_portfolio_rebalance_notification_option) do
            create(:investment_portfolio_rebalance_notification_option, :webhook, investment_portfolio:)
          end

          it 'deletes the investment portfolio rebalance notification option' do
            delete "/api/investment_portfolio_rebalance_notification_options/#{investment_portfolio_rebalance_notification_option.id}",
                   headers: valid_headers, as: :json

            expect(response).to have_http_status(:no_content)
            expect(InvestmentPortfolioRebalanceNotificationOption.count).to be_zero
          end
        end

        context 'when the investment portfolio does not belong to the user' do
          let(:another_user) { create(:user) }
          let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }
          let(:investment_portfolio_rebalance_notification_option) do
            create(:investment_portfolio_rebalance_notification_option, :webhook, investment_portfolio:)
          end

          it 'returns a not found status' do
            delete "/api/investment_portfolio_rebalance_notification_options/#{investment_portfolio_rebalance_notification_option.id}",
                   headers: valid_headers, as: :json

            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context 'when the investment portfolio rebalance notification option does not exist' do
        it 'returns a not found status' do
          delete '/api/investment_portfolio_rebalance_notification_options/1', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        delete '/api/investment_portfolio_rebalance_notification_options/1', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
