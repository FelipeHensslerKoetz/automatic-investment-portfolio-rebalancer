# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CustomAssets', type: :request do
  let(:user) { create(:user) }

  let(:valid_headers) do
    user.create_new_auth_token.merge('Accept' => 'application/vnd.investment_portfolio_rebalancer.v1')
  end

  let(:invalid_headers) do
    { 'Accept' => 'application/vnd.investment_portfolio_rebalancer.v1' }
  end

  describe 'GET /index' do
    context 'when user is authenticated' do
      context 'when the user has custom assets' do
        let(:another_user) { create(:user) }

        let!(:another_user_asset) { create(:asset, custom: true, user: another_user) }
        let!(:user_first_custom_asset) { create(:asset, custom: true, user:) }
        let!(:user_second_custom_asset) { create(:asset, custom: true, user:) }

        let(:serialized_user_first_custom_asset) { AssetSerializer.new(user_first_custom_asset).as_json }
        let(:serialized_user_second_custom_asset) { AssetSerializer.new(user_second_custom_asset).as_json }

        before do
          create(:asset, custom: false)
        end

        it 'returns a list of custom assets' do
          get '/api/custom_assets', headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body.size).to eq(2)
          expect(response.parsed_body.map(&:deep_symbolize_keys)).to include(
            serialized_user_first_custom_asset,
            serialized_user_second_custom_asset
          )
        end
      end

      context 'when the user has no custom assets' do
        it 'returns an empty list' do
          get '/api/custom_assets', headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body.size).to eq(0)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/custom_assets', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /show' do
    context 'when the user is authenticated' do
      let!(:another_user) { create(:user) }
      let!(:another_user_custom_asset) { create(:asset, custom: true, user: another_user) }
      let!(:user_custom_asset) { create(:asset, custom: true, user:) }
      let!(:non_custom_asset) { create(:asset, custom: false) }

      context 'when the custom asset exists' do
        let(:serialized_user_custom_asset) { AssetSerializer.new(user_custom_asset).as_json }

        it 'returns the custom asset' do
          get "/api/custom_assets/#{user_custom_asset.id}", headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body.deep_symbolize_keys).to eq(serialized_user_custom_asset)
        end
      end

      context 'when the custom asset does not exist' do
        it 'returns asset not found' do
          get '/api/custom_assets/-1', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the custom asset belongs to another user' do
        it 'returns asset not found' do
          get "/api/custom_assets/#{another_user_custom_asset.id}", headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the asset is not custom' do
        it 'returns asset not found' do
          get "/api/custom_assets/#{non_custom_asset.id}", headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/custom_assets/1', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /destroy' do
    context 'when the user is authenticated' do
      let!(:another_user) { create(:user) }
      let!(:another_user_custom_asset) { create(:asset, custom: true, user: another_user) }
      let!(:user_custom_asset) { create(:asset, custom: true, user:) }
      let!(:non_custom_asset) { create(:asset, custom: false) }

      context 'when the custom asset belongs to the user' do
        it 'deletes the custom asset' do
          delete "/api/custom_assets/#{user_custom_asset.id}", headers: valid_headers, as: :json

          expect(response).to have_http_status(:no_content)
          expect(Asset.find_by(id: user_custom_asset.id)).to be_nil
        end
      end

      context 'when the custom asset belongs to another user' do
        it 'returns asset not found' do
          delete "/api/custom_assets/#{another_user_custom_asset.id}", headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the asset is not custom' do
        it 'returns asset not found' do
          delete "/api/custom_assets/#{non_custom_asset.id}", headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the custom does not exist' do
        it 'returns asset not found' do
          delete '/api/custom_assets/-1', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized status' do
        delete '/api/custom_assets/1', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /create' do
    context 'when the user is authenticated' do
      context 'when the custom asset_params are valid' do
        let(:asset_params) do
          {
            custom_asset: {
              name: 'My Custom Asset',
              price: 100.0,
              currency_code: 'BRL'
            }
          }
        end

        before do
          create(:currency, code: 'BRL')
        end

        it 'creates the custom asset and the asset_price' do
          post '/api/custom_assets', headers: valid_headers, params: asset_params, as: :json

          custom_asset = Asset.find_by(name: 'My Custom Asset')
          serialized_response = AssetSerializer.new(custom_asset).as_json

          expect(response).to have_http_status(:created)
          expect(response.parsed_body.deep_symbolize_keys).to eq(serialized_response.deep_symbolize_keys)

          expect(custom_asset.name).to eq('My Custom Asset')
          expect(custom_asset.user_id).to eq(user.id)
          expect(custom_asset.custom).to be_truthy
          expect(custom_asset.kind).to eq('custom')
          expect(custom_asset.ticker_symbol).to eq("#{user.email} - #{custom_asset.name}")
          expect(Asset.count).to eq(1)

          asset_price = custom_asset.asset_prices.first
          expect(custom_asset.asset_prices.count).to eq(1)
          expect(asset_price.price).to eq(100.0)
          expect(asset_price.status).to eq('updated')
          expect(asset_price.partner_resource).to be_nil
        end
      end

      context 'when the custom asset_params are invalid' do
        let(:asset_params) do
          {
            custom_asset: {
              name: nil,
              price: nil,
              currency_code: nil
            }
          }
        end

        it 'return unprocessable_entity' do
          post '/api/custom_assets', headers: valid_headers, params: asset_params, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body).to eq({ 'error' => "Validation failed: Name can't be blank" })
        end
      end

      context 'when the params are valid but the record already exists' do
        let(:asset_params) do
          {
            custom_asset: {
              name: 'My Custom Asset',
              price: 100.0,
              currency_code: 'BRL'
            }
          }
        end

        before do
          create(:asset, custom: true, user:, name: 'My Custom Asset')
        end

        it 'returns unprocessable_entity' do
          post '/api/custom_assets', headers: valid_headers, params: asset_params, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body).to eq({ 'error' => 'Validation failed: Currency must exist' })
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized status' do
        post '/api/custom_assets', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /update' do
    context 'when the user is authenticated' do
      context 'when the custom asset belongs to the user' do
        let!(:custom_asset) { create(:asset, custom: true, user:, kind: 'custom') }
        let!(:custom_asset_asset_price) { create(:asset_price, asset: custom_asset) }

        context 'when the update params are valid' do
          context 'when no rebalance_order is in process' do
            let(:custom_asset_params) do
              {
                custom_asset: {
                  name: 'My Custom Asset Updated',
                  price: 200.0,
                  currency_code: 'USD'
                }
              }
            end

            before do
              create(:currency, code: 'USD')
            end

            it 'updates the custom asset and the asset_price' do
              put "/api/custom_assets/#{custom_asset.id}", headers: valid_headers, params: custom_asset_params, as: :json

              custom_asset.reload
              serialized_response = AssetSerializer.new(custom_asset).as_json

              expect(response).to have_http_status(:ok)
              expect(response.parsed_body.deep_symbolize_keys).to eq(serialized_response.deep_symbolize_keys)

              expect(custom_asset.name).to eq('My Custom Asset Updated')
              expect(custom_asset.user_id).to eq(user.id)
              expect(custom_asset.custom).to be_truthy
              expect(custom_asset.kind).to eq('custom')
              expect(custom_asset.ticker_symbol).to eq("#{user.email} - My Custom Asset Updated")
              expect(Asset.count).to eq(1)

              asset_price = custom_asset.asset_prices.first
              expect(custom_asset.asset_prices.count).to eq(1)
              expect(asset_price.price).to eq(200.0)
              expect(asset_price.status).to eq('updated')
              expect(asset_price.partner_resource).to be_nil
            end
          end

          context 'when a rebalance_order is in process' do
            let(:custom_asset_params) do
              {
                custom_asset: {
                  name: 'My Custom Asset Updated',
                  price: 200.0,
                  currency_code: 'USD'
                }
              }
            end

            before do
              create(:currency, code: 'USD')
              create(:rebalance_order, status: 'scheduled', user:)
            end

            it 'returns unprocessable_entity' do
              put "/api/custom_assets/#{custom_asset.id}", headers: valid_headers, params: custom_asset_params, as: :json

              expect(response).to have_http_status(:unprocessable_entity)
              expect(response.parsed_body).to eq({ 'error' => 'Asset cannot be updated while there is a RebalanceOrder being processed or scheduled.' })
            end
          end
        end

        context 'when the update params are invalid' do
          let(:custom_asset_params) do
            {
              custom_asset: {
                currency_code: 'LTC'
              }
            }
          end

          it 'returns unprocessable_entity' do
            put "/api/custom_assets/#{custom_asset.id}", headers: valid_headers, params: custom_asset_params, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body).to eq({ 'error' => "Couldn't find Currency" })
          end
        end
      end

      context 'when the custom asset belongs to another user' do
        let!(:another_user) { create(:user) }
        let!(:another_user_custom_asset) { create(:asset, custom: true, user: another_user) }

        let(:custom_asset_params) do
          {
            custom_asset: {
              name: 'My Custom Asset',
              price: 100.0,
              currency_code: 'BRL'
            }
          }
        end

        it 'returns asset not found' do
          put "/api/custom_assets/#{another_user_custom_asset.id}", headers: valid_headers, params: custom_asset_params, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the asset is not custom' do
        let!(:non_custom_asset) { create(:asset, custom: false) }

        let(:custom_asset_params) do
          {
            custom_asset: {
              name: 'My Custom Asset',
              price: 100.0,
              currency_code: 'BRL'
            }
          }
        end

        it 'returns asset not found' do
          put "/api/custom_assets/#{non_custom_asset.id}", headers: valid_headers, params: custom_asset_params, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized status' do
        put '/api/custom_assets/1', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
