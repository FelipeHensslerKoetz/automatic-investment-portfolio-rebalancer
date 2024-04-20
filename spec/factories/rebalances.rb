FactoryBot.define do
  factory :rebalance do
    rebalance_order { nil }
    before_state { "" }
    after_state { "" }
    details { "" }
    recommended_actions { "" }
    status { "MyString" }
    error_message { "MyString" }
  end
end
