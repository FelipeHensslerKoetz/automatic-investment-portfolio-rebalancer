FactoryBot.define do
  factory :investment_portfolio_rebalance_notification_order do
    rebalance_order { create(:rebalance_order, :default) }
    investment_portfolio { rebalance_order.investment_portfolio }
    rebalance { create(:rebalance, rebalance_order: rebalance_order) }

    trait :pending do
      status { "pending" }
    end

    trait :processing do
      status { "processing" }
    end

    trait :success do
      status { "success" }
    end

    trait :error do
      status { "error" }
    end

    trait :with_webhook_investment_portfolio_rebalance_notification_option do 
      investment_portfolio_rebalance_notification_option { create(:investment_portfolio_rebalance_notification_option, :webhook, investment_portfolio: investment_portfolio) }
    end

    trait :with_email_investment_portfolio_rebalance_notification_option do
      investment_portfolio_rebalance_notification_option { create(:investment_portfolio_rebalance_notification_option, :email, investment_portfolio: investment_portfolio) }
    end
  end
end
