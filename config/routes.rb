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

      resources :rebalance_orders

      resources :currencies, only: %i[index show]

      resources :investment_portfolios, only: %i[index show create update destroy] do 
        collection do 
          post ':id/investment_portfolio_assets', to: 'investment_portfolios#investment_portfolio_assets', as: :investment_portfolio_assets
        end
      end

      resources :custom_assets
      resources :customer_support_items
      resources :customer_support_item_messages, only: %i[index show create]
    end

    scope module: :v2, constraints: ApiConstraints.new({ version: 2, default: false }) do
    end
  end
end
