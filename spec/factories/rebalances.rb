# frozen_string_literal: true

FactoryBot.define do
  factory :rebalance do
    rebalance_order { create(:rebalance_order) }
    before_state { { 'data' => [] } }
    after_state { { 'data' => [] } }
    details { { 'data' => [] } }
    recommended_actions { { buy: [], sell: [] } }
  end
end
