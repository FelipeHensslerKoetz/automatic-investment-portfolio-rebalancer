require 'rails_helper'

RSpec.describe 'Assets', type: :request do
  let(:user) { create(:user) }

  let(:valid_headers) do
    user.create_new_auth_token.merge('Accept' => 'application/vnd.investment_portfolio_rebalancer.v1')
  end

  let(:invalid_headers) do
    { 'Accept' => 'application/vnd.investment_portfolio_rebalancer.v1' }
  end

  describe 'GET /index' do
    context 'when user is authenticated' do
      context 'when there are assets' do
        let!(:assets) { create_list(:asset, 3) }

        it 'returns a list of assets' do
          get '/api/assets', headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body.size).to eq(3)
        end
      end

      context 'when there are no assets' do
        it 'returns an empty list' do
          get '/api/assets', headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body.size).to eq(0)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/assets', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /show' do
    let(:asset) { create(:asset) }

    context 'when the user is authenticated' do
      context 'when the asset exists' do
        it 'returns the asset' do
          get "/api/assets/#{asset.id}", headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body['id']).to eq(asset.id)
        end
      end

      context 'when the asset does not exist' do
        it 'returns a 404' do
          get '/api/assets/-1', headers: valid_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized status' do
        get "/api/assets/#{asset.id}", headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /search' do
    context 'when user is authenticated' do
      context 'when there are matching assets' do
        let!(:assets) { create(:asset, name: 'Bitcoin', ticker_symbol: 'BTC') }

        context 'when matching by asset name' do
          it 'returns a list of assets' do
            get '/api/assets/search?asset=bitcoin', headers: valid_headers, as: :json

            expect(response).to be_successful
            expect(response.parsed_body.size).to eq(1)
          end
        end

        context 'when matching by asset identifier' do
          it 'returns a list of assets' do
            get '/api/assets/search?asset=btc', headers: valid_headers, as: :json

            expect(response).to be_successful
            expect(response.parsed_body.size).to eq(1)
          end
        end
      end

      context 'when there are no matching assets' do
        it 'returns an empty list' do
          get '/api/assets/search?asset=Bitcoin', headers: valid_headers, as: :json

          expect(response).to be_successful
          expect(response.parsed_body.size).to eq(0)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/assets/search', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /deep_search' do
    context 'when user is authenticated' do
      it 'schedules an asset discovery job' do
        expect do
          get '/api/assets/deep_search?asset=Bitcoin', headers: valid_headers, as: :json
        end.to change(AssetDiscoveryJob.jobs, :size).by(1)
      end

      it 'returns a success message' do
        get '/api/assets/deep_search?asset=Bitcoin', headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response.parsed_body['message']).to eq('Asset discovery job has been scheduled')
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized status' do
        get '/api/assets/deep_search', headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
