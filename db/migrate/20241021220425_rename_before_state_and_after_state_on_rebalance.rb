class RenameBeforeStateAndAfterStateOnRebalance < ActiveRecord::Migration[6.1]
  def change
    rename_column :rebalances, :before_state, :current_investment_portfolio_state
    rename_column :rebalances, :after_state, :projected_investment_portfolio_state_with_rebalance_actions
  end

  def down
    rename_column :rebalances, :current_investment_portfolio_state, :before_state
    rename_column :rebalances, :projected_investment_portfolio_state_with_rebalance_actions, :after_state
  end
end
