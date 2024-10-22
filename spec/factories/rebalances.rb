# frozen_string_literal: true

FactoryBot.define do
  factory :rebalance do
    rebalance_order { create(:rebalance_order, :default) }
    current_investment_portfolio_state { [] }
    projected_investment_portfolio_state_with_rebalance_actions { [] }
    details { {} }
    recommended_actions { { buy: [], sell: [] } }
  end
end
