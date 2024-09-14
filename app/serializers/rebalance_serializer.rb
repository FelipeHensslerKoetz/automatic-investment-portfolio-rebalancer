
class RebalanceSerializer < ActiveModel::Serializer
  attributes :investment_portfolio_projected_total_value, :before_state, :after_state, :buy, :sell

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

  def before_state 
    object['before_state'].map do |asset|
      {
        'ticker_symbol': asset['ticker_symbol'],
        'price': asset['price'],
        'quantity': asset['quantity'].to_f.truncate(2).to_s,
        'current_total_value': asset['current_total_value'].to_f.truncate(2).to_s,
        'current_allocation_weight_percentage': asset['current_allocation_weight_percentage'].to_f.truncate(2).to_s
      }
    end
  end

  def after_state
    object['after_state'].map do |asset|
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