# frozen_string_literal: true

FactoryBot.define do
  factory :rebalance do
    rebalance_order { create(:rebalance_order) }
    before_state { [] }
    after_state { [] }
    details { {} }
    recommended_actions { { buy: [], sell: [] } }
  end
end
