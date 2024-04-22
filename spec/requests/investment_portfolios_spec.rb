# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'InvestmentPortfolios', type: :request do
  let(:user) { create(:user) }

  let(:valid_headers) do
    user.create_new_auth_token.merge('Accept' => 'application/vnd.investment_portfolio_rebalancer.v1')
  end

  let(:invalid_headers) do
    { 'Accept' => 'application/vnd.investment_portfolio_rebalancer.v1' }
  end

  let(:currency) { create(:currency, code: 'BRL') }
  let(:another_currency) { create(:currency, code: 'USD') }
  let(:asset) { create(:asset, ticker_symbol: 'PETR4') }
  let(:another_asset) { create(:asset, ticker_symbol: 'VALE3') }

  describe 'GET /index' do
    context 'when the user is authenticated' do
      context 'when the user has investment portfolios' do
        let!(:investment_portfolio) { create(:investment_portfolio, user:) }
        let!(:another_investment_portfolio) { create(:investment_portfolio, user:) }

        before { get '/api/investment_portfolios', headers: valid_headers, as: :json }

        it 'returns a list of investment portfolios' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(investment_portfolio.to_json,
                                           another_investment_portfolio.to_json)
        end
      end

      context 'when the user does not have investment portfolios' do
        before { get '/api/investment_portfolios', headers: valid_headers, as: :json }

        it 'returns an empty list' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to eq('[]')
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/investment_portfolios', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /show' do
    context 'when the user is authenticated' do
      context 'when the investment portfolio belongs to the user' do
        let(:investment_portfolio) { create(:investment_portfolio, user:) }

        before { get "/api/investment_portfolios/#{investment_portfolio.id}", headers: valid_headers, as: :json }

        it 'returns the investment portfolio' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to eq(investment_portfolio.to_json)
        end
      end

      context 'when the investment portfolio does not belong to the user' do
        let(:another_user) { create(:user) }
        let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }

        it 'returns a not found status' do
          get "/api/investment_portfolios/#{investment_portfolio.id}", headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the investment portfolio does not exist' do
        it 'returns a not found status' do
          get '/api/investment_portfolios/-1', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/investment_portfolios/1', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /create' do
    context 'when the user is authenticated' do
      context 'when params are valid' do
        let(:investment_portfolio_params) do
          {
            investment_portfolio: {
              name: 'My Investment Portfolio',
              description: 'My first investment portfolio',
              currency_id: currency.id,
              investment_portfolio_assets_attributes: [
                {
                  asset_id: asset.id,
                  quantity: 100,
                  allocation_weight: 100
                }
              ]
            }
          }
        end

        before { post '/api/investment_portfolios', headers: valid_headers, params: investment_portfolio_params, as: :json }

        it 'creates an investment portfolio and investment_portfolio_assets' do
          new_investment_portfolio = InvestmentPortfolio.last
          investment_portfolio_asset = new_investment_portfolio.investment_portfolio_assets.first

          expect(response).to have_http_status(:created)
          expect(response.body).to eq(new_investment_portfolio.to_json)
          expect(new_investment_portfolio.name).to eq('My Investment Portfolio')
          expect(new_investment_portfolio.description).to eq('My first investment portfolio')
          expect(new_investment_portfolio.currency).to eq(currency)
          expect(investment_portfolio_asset.asset).to eq(asset)
          expect(investment_portfolio_asset.quantity).to eq(100)
          expect(investment_portfolio_asset.allocation_weight).to eq(100)
          expect(InvestmentPortfolio.count).to eq(1)
          expect(InvestmentPortfolioAsset.count).to eq(1)
        end
      end

      context 'when params are invalid' do
        before { post '/api/investment_portfolios', headers: valid_headers, as: :json }

        it 'does not create an investment portfolio' do
          expect(response).to have_http_status(:bad_request)
          expect(InvestmentPortfolio.count).to eq(0)
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized status' do
        post '/api/investment_portfolios', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /update' do
    context 'when the user is authenticated' do
      context 'when the investment portfolio belongs to the user' do
        let(:investment_portfolio) { create(:investment_portfolio, user:) }

        context 'when params are valid' do
          context 'when creating a new investment portfolio asset' do
            let(:investment_portfolio_params) do
              {
                investment_portfolio_assets_attributes: [
                  {
                    asset_id: asset.id,
                    quantity: 250,
                    allocation_weight: 50
                  }
                ]
              }
            end

            before do
              patch "/api/investment_portfolios/#{investment_portfolio.id}", headers: valid_headers,
                                                                             params: investment_portfolio_params, as: :json
            end

            it 'creates a new investment_portfolio_asset' do
              investment_portfolio_asset = investment_portfolio.investment_portfolio_assets.first
              expect(response).to have_http_status(:ok)
              expect(investment_portfolio.reload.investment_portfolio_assets.count).to eq(1)
              expect(investment_portfolio_asset.attributes).to include(
                'asset_id' => asset.id,
                'quantity' => 250,
                'allocation_weight' => 50,
                'investment_portfolio_id' => investment_portfolio.id
              )

              expect(response.parsed_body).to eq(investment_portfolio.as_json)
            end
          end

          context 'when updating an existing investment portfolio asset' do
            let!(:investment_portfolio_asset) do
              create(:investment_portfolio_asset, investment_portfolio:, asset:)
            end

            let(:investment_portfolio_params) do
              {
                investment_portfolio_assets_attributes: [
                  {
                    id: investment_portfolio_asset.id,
                    asset_id: asset.id,
                    quantity: 1000,
                    allocation_weight: 100
                  }
                ]
              }
            end

            before do
              patch "/api/investment_portfolios/#{investment_portfolio.id}", headers: valid_headers,
                                                                             params: investment_portfolio_params, as: :json
            end

            it 'updates the investment_portfolio_asset' do
              investment_portfolio_asset.reload
              expect(response).to have_http_status(:ok)
              expect(investment_portfolio.reload.investment_portfolio_assets.count).to eq(1)
              expect(investment_portfolio_asset.attributes).to include(
                'asset_id' => asset.id,
                'quantity' => 1000,
                'allocation_weight' => 100,
                'investment_portfolio_id' => investment_portfolio.id
              )
              expect(response.parsed_body).to eq(investment_portfolio.as_json)
            end
          end

          context 'when removing an existing investment portfolio asset' do
            let!(:investment_portfolio_asset) do
              create(:investment_portfolio_asset, investment_portfolio:, asset:)
            end

            let(:investment_portfolio_params) do
              {
                investment_portfolio_assets_attributes: [
                  {
                    id: investment_portfolio_asset.id,
                    _destroy: true
                  }
                ]
              }
            end

            before do
              patch "/api/investment_portfolios/#{investment_portfolio.id}", headers: valid_headers,
                                                                             params: investment_portfolio_params, as: :json
            end

            it 'removes the investment_portfolio_asset' do
              expect(response).to have_http_status(:ok)
              expect(investment_portfolio.reload.investment_portfolio_assets.count).to eq(0)
              expect(InvestmentPortfolioAsset.find_by(id: investment_portfolio_asset.id)).to be_nil
              expect(response.parsed_body).to eq(investment_portfolio.as_json)
            end
          end

          context 'when updating the investment portfolio' do
            let(:investment_portfolio_params) do
              {
                name: 'My Updated Investment Portfolio',
                description: 'My updated description',
                currency_id: another_currency.id
              }
            end

            before do
              patch "/api/investment_portfolios/#{investment_portfolio.id}", headers: valid_headers,
                                                                             params: investment_portfolio_params, as: :json
            end

            it 'updates the investment portfolio' do
              expect(response).to have_http_status(:ok)
              expect(investment_portfolio.reload.attributes).to include(
                'name' => 'My Updated Investment Portfolio',
                'description' => 'My updated description',
                'currency_id' => another_currency.id
              )
              expect(response.parsed_body).to eq(investment_portfolio.as_json)
            end
          end
        end

        context 'when params are invalid' do
          let(:investment_portfolio_params) { {} }

          before do
            patch "/api/investment_portfolios/#{investment_portfolio.id}",
                  headers: valid_headers,
                  params: investment_portfolio_params, as: :json
          end

          it 'does not update the investment portfolio' do
            expect(response).to have_http_status(:bad_request)
          end
        end
      end

      context 'when the investment portfolio does not belong to the user' do
        let(:another_user) { create(:user) }
        let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }

        it 'returns a not found status' do
          patch "/api/investment_portfolios/#{investment_portfolio.id}", headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the investment portfolio does not exist' do
        it 'returns a not found status' do
          patch '/api/investment_portfolios/-1', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized status' do
        patch '/api/investment_portfolios/1', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /destroy' do
    context 'when the user is authenticated' do
      context 'when the investment portfolio belongs to the user' do
        let(:investment_portfolio) { create(:investment_portfolio, user:) }

        context 'when there are no related models' do
          before { delete "/api/investment_portfolios/#{investment_portfolio.id}", headers: valid_headers, as: :json }

          it 'returns a no content status' do
            expect(response).to have_http_status(:no_content)
            expect(InvestmentPortfolio.find_by(id: investment_portfolio.id)).to be_nil
          end
        end

        context 'when there are related models' do
          before do
            create(:investment_portfolio_asset, investment_portfolio:, asset:)
          end

          it 'returns an unprocessable entity status' do
            delete "/api/investment_portfolios/#{investment_portfolio.id}", headers: valid_headers, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
            expect(InvestmentPortfolio.find_by(id: investment_portfolio.id)).to be_present
          end
        end
      end

      context 'when the investment portfolio does not belong to the user' do
        let(:another_user) { create(:user) }
        let(:investment_portfolio) { create(:investment_portfolio, user: another_user) }

        it 'returns a not found status' do
          delete "/api/investment_portfolios/#{investment_portfolio.id}", headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
          expect(InvestmentPortfolio.find_by(id: investment_portfolio.id)).to be_present
        end
      end

      context 'when the investment portfolio does not exist' do
        it 'returns a not found status' do
          delete '/api/investment_portfolios/-1', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized status' do
        delete '/api/investment_portfolios/1', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
