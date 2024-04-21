require 'api_constraints'

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    mount_devise_token_auth_for 'User', at: 'auth'

    scope module: :v1, constraints: ApiConstraints.new({ version: 1, default: true }) do
      resources :assets, only: %i[index show] do
        collection do
          get :search, to: 'assets#search'
          get :deep_search, to: 'assets#deep_search'
        end
      end

      resources :currencies, only: %i[index show]
    end

    scope module: :v2, constraints: ApiConstraints.new({ version: 2, default: false }) do
    end
  end
end
