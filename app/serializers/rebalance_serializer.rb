
class RebalanceSerializer < ActiveModel::Serializer
  attributes :investment_portfolio_projected_total_value, :current_investment_portfolio_state, :projected_investment_portfolio_state_with_rebalance_actions, :buy, :sell

  def investment_portfolio_projected_total_value
    object['details']['investment_portfolio_projected_total_value']
  end

  def buy 
    object['recommended_actions']['buy'].map do |action|
      {
        'ticker_symbol': action['ticker_symbol'],
        'quantity': action['quantity'].to_f.truncate(2).to_s,
      }
    end
  end

  def sell 
    object['recommended_actions']['sell'].map do |action|
      {
        'ticker_symbol': action['ticker_symbol'],
        'quantity': action['quantity'].to_f.truncate(2).to_s,
      }
    end
  end

  def current_investment_portfolio_state 
    object['current_investment_portfolio_state'].map do |asset|
      {
        'ticker_symbol': asset['ticker_symbol'],
        'price': asset['price'],
        'quantity': asset['quantity'].to_f.truncate(2).to_s,
        'current_total_value': asset['current_total_value'].to_f.truncate(2).to_s,
        'current_allocation_weight_percentage': asset['current_allocation_weight_percentage'].to_f.truncate(2).to_s
      }
    end
  end

  def projected_investment_portfolio_state_with_rebalance_actions
    object['projected_investment_portfolio_state_with_rebalance_actions'].map do |asset|
      {
        'ticker_symbol': asset['ticker_symbol'],
        'price': asset['price'],
        'quantity': asset['quantity'].to_f.truncate(2).to_s,
        'current_total_value': asset['current_total_value'].to_f.truncate(2).to_s,
        'current_allocation_weight_percentage': asset['current_allocation_weight_percentage'].to_f.truncate(2).to_s
      }
    end
  end
end