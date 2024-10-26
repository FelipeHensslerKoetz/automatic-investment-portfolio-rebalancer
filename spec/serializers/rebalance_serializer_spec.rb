require  'rails_helper'

RSpec.describe RebalanceSerializer do
  let(:rebalance) { create(:rebalance) }
  let(:serializer) { described_class.new(rebalance) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer).to_json }
  let(:parsed_response) { JSON.parse(serialization) }

  it 'serializes the investment_portfolio_projected_total_value' do
    expect(parsed_response['investment_portfolio_projected_total_value']).to eq(rebalance['details']['investment_portfolio_projected_total_value'])
  end

  it 'serializes the buy' do
    expect(parsed_response['buy']).to eq(rebalance['recommended_actions']['buy'].map do |action|
      {
        'ticker_symbol': action['ticker_symbol'],
        'quantity': action['quantity'].to_f.truncate(2).to_s,
      }
    end)
  end

  it 'serializes the sell' do
    expect(parsed_response['sell']).to eq(rebalance['recommended_actions']['sell'].map do |action|
      {
        'ticker_symbol': action['ticker_symbol'],
        'quantity': action['quantity'].to_f.truncate(2).to_s,
      }
    end)
  end

  it 'serializes the current_investment_portfolio_state' do
    expect(parsed_response['current_investment_portfolio_state']).to eq(rebalance['current_investment_portfolio_state'].map do |asset|
      {
        'ticker_symbol': asset['ticker_symbol'],
        'price': asset['price'],
        'quantity': asset['quantity'].to_f.truncate(2).to_s,
        'current_total_value': asset['current_total_value'].to_f.truncate(2).to_s,
        'current_allocation_weight_percentage': asset['current_allocation_weight_percentage'].to_f.truncate(2).to_s
      }
    end)
  end

  it 'serializes the projected_investment_portfolio_state_with_rebalance_actions' do
    expect(parsed_response['projected_investment_portfolio_state_with_rebalance_actions']).to eq(rebalance['projected_investment_portfolio_state_with_rebalance_actions'].map do |asset|
      {
        'ticker_symbol': asset['ticker_symbol'],
        'price': asset['price'],
        'quantity': asset['quantity'].to_f.truncate(2).to_s,
        'current_total_value': asset['current_total_value'].to_f.truncate(2).to_s,
        'current_allocation_weight_percentage': asset['current_allocation_weight_percentage'].to_f.truncate(2).to_s
      }
    end)
  end
end