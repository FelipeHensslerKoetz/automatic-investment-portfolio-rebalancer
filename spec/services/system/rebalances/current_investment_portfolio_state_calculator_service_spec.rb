require 'rails_helper'

RSpec.describe System::Rebalances::CurrentInvestmentPortfolioStateCalculatorService do
  describe '.call' do
    subject(:current_investment_portfolio_state) { described_class.call(investment_portfolio:, amount:) }

    let(:user) { create(:user) }
    let!(:brl_currency) { create(:currency, :brl) }
    let(:usd_currency) { create(:currency, :usd) }
    let(:amount) { rebalance_order.amount }
    let(:investment_portfolio) { create(:investment_portfolio, user:) }

    before do
      asset = create(:asset, ticker_symbol: 'IVVB11')
      create(:asset_price, :with_hg_brasil_assets_partner_resource, asset:, currency: usd_currency, status: :updated, price: 40.0)
      create(:investment_portfolio_asset, investment_portfolio:, asset:, target_allocation_weight_percentage: 50, quantity: 10)

      second_asset = create(:asset, ticker_symbol: 'BOVA11')
      create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: second_asset, currency: brl_currency, status: :updated,
                                                                    price: 100.0)
      create(:investment_portfolio_asset, investment_portfolio:, asset: second_asset, target_allocation_weight_percentage: 50,
                                          quantity: 10)

      brl_usd_currency_parity = create(:currency_parity, currency_from: usd_currency, currency_to: brl_currency)
      create(:currency_parity_exchange_rate, :with_hg_brasil_currencies_partner_resource, currency_parity: brl_usd_currency_parity,
                                                                                          exchange_rate: 5.0,
                                                                                          status: :updated)
    end

    

    context 'when rebalance_order kind is default' do
      context 'when not depositing or withdrawing money' do
        let(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, investment_portfolio:) }
  
        it 'calculates the before state and investment_portfolio_projected_total_value' do
          before_state = current_investment_portfolio_state
  
          expect(before_state[:investment_portfolio_projected_total_value]).to eq(3000.0)
          expect(before_state[:current_investment_portfolio_state].count).to eq(2)
  
          ivvb_11_asset = before_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'IVVB11' }
          expect(ivvb_11_asset[:ticker_symbol]).to eq('IVVB11')
          expect(ivvb_11_asset[:quantity]).to eq(BigDecimal(10))
          expect(ivvb_11_asset[:target_allocation_weight_percentage]).to eq(BigDecimal(50))
          expect(ivvb_11_asset[:target_variation_limit_percentage]).to be_nil
          expect(ivvb_11_asset[:average_price]).to be_nil
          expect(ivvb_11_asset[:price]).to eq(200.0)
          expect(ivvb_11_asset[:currency]).to eq(brl_currency)
          expect(ivvb_11_asset[:original_price]).to eq(40.0)
          expect(ivvb_11_asset[:original_currency]).to eq(usd_currency)
          expect(ivvb_11_asset[:asset_price]).to be_an_instance_of(AssetPrice)
          expect(ivvb_11_asset[:currency_parity_exchange_rate]).to be_an_instance_of(CurrencyParityExchangeRate)
          expect(ivvb_11_asset[:current_total_value]).to eq(2000.0)
          expect(ivvb_11_asset[:current_allocation_weight_percentage]).to eq(BigDecimal('0.666666666666666666666666666666666667e2'))
          expect(ivvb_11_asset[:current_variation_percentage]).to eq(BigDecimal('0.166666666666666666666666666666666667e2'))
          expect(ivvb_11_asset[:target_total_value]).to eq(1500.0)
          expect(ivvb_11_asset[:target_quantity]).to eq(7.5)
          expect(ivvb_11_asset[:quantity_adjustment]).to eq(-2.5)
  
          bova_11_asset = before_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'BOVA11' }
          expect(bova_11_asset[:ticker_symbol]).to eq('BOVA11')
          expect(bova_11_asset[:quantity]).to eq(BigDecimal(10))
          expect(bova_11_asset[:target_allocation_weight_percentage]).to eq(BigDecimal(50))
          expect(bova_11_asset[:target_variation_limit_percentage]).to be_nil
          expect(bova_11_asset[:average_price]).to be_nil
          expect(bova_11_asset[:price]).to eq(100.0)
          expect(bova_11_asset[:currency]).to eq(brl_currency)
          expect(bova_11_asset[:original_price]).to eq(100.0)
          expect(bova_11_asset[:original_currency]).to eq(brl_currency)
          expect(bova_11_asset[:asset_price]).to be_an_instance_of(AssetPrice)
          expect(bova_11_asset[:currency_parity_exchange_rate]).to be_nil
          expect(bova_11_asset[:current_total_value]).to eq(1000.0)
          expect(bova_11_asset[:current_allocation_weight_percentage]).to eq(BigDecimal('0.333333333333333333333333333333333333e2'))
          expect(bova_11_asset[:current_variation_percentage]).to eq(BigDecimal('-0.166666666666666666666666666666666667e2'))
          expect(bova_11_asset[:target_total_value]).to eq(1500.0)
          expect(bova_11_asset[:target_quantity]).to eq(15.0)
          expect(bova_11_asset[:quantity_adjustment]).to eq(5.0)
        end
      end
  
      context 'when depositing some money' do
        let(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, investment_portfolio:, amount: 3000) }
  
        it 'calculates the before state and investment_portfolio_projected_total_value' do
          before_state = current_investment_portfolio_state
  
          expect(before_state[:investment_portfolio_projected_total_value]).to eq(6000.0)
          expect(before_state[:current_investment_portfolio_state].count).to eq(2)
  
          ivvb_11_asset = before_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'IVVB11' }
          expect(ivvb_11_asset[:ticker_symbol]).to eq('IVVB11')
          expect(ivvb_11_asset[:quantity]).to eq(BigDecimal(10))
          expect(ivvb_11_asset[:target_allocation_weight_percentage]).to eq(BigDecimal(50))
          expect(ivvb_11_asset[:target_variation_limit_percentage]).to be_nil
          expect(ivvb_11_asset[:average_price]).to be_nil
          expect(ivvb_11_asset[:price]).to eq(200.0)
          expect(ivvb_11_asset[:currency]).to eq(brl_currency)
          expect(ivvb_11_asset[:original_price]).to eq(40.0)
          expect(ivvb_11_asset[:original_currency]).to eq(usd_currency)
          expect(ivvb_11_asset[:asset_price]).to be_an_instance_of(AssetPrice)
          expect(ivvb_11_asset[:currency_parity_exchange_rate]).to be_an_instance_of(CurrencyParityExchangeRate)
          expect(ivvb_11_asset[:current_total_value]).to eq(2000.0)
          expect(ivvb_11_asset[:current_allocation_weight_percentage]).to eq(BigDecimal('0.333333333333333333333333333333333333e2'))
          expect(ivvb_11_asset[:current_variation_percentage]).to eq(BigDecimal('-0.166666666666666666666666666666666667e2'))
          expect(ivvb_11_asset[:target_total_value]).to eq(3000.0)
          expect(ivvb_11_asset[:target_quantity]).to eq(15.0)
          expect(ivvb_11_asset[:quantity_adjustment]).to eq(5.0)
  
          bova_11_asset = before_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'BOVA11' }
          expect(bova_11_asset[:ticker_symbol]).to eq('BOVA11')
          expect(bova_11_asset[:quantity]).to eq(BigDecimal(10))
          expect(bova_11_asset[:target_allocation_weight_percentage]).to eq(BigDecimal(50))
          expect(bova_11_asset[:target_variation_limit_percentage]).to be_nil
          expect(bova_11_asset[:average_price]).to be_nil
          expect(bova_11_asset[:price]).to eq(100.0)
          expect(bova_11_asset[:currency]).to eq(brl_currency)
          expect(bova_11_asset[:original_price]).to eq(100.0)
          expect(bova_11_asset[:original_currency]).to eq(brl_currency)
          expect(bova_11_asset[:asset_price]).to be_an_instance_of(AssetPrice)
          expect(bova_11_asset[:currency_parity_exchange_rate]).to be_nil
          expect(bova_11_asset[:current_total_value]).to eq(1000.0)
          expect(bova_11_asset[:current_allocation_weight_percentage]).to eq(BigDecimal('0.166666666666666666666666666666666667e2'))
          expect(bova_11_asset[:current_variation_percentage]).to eq(BigDecimal('-0.333333333333333333333333333333333333e2'))
          expect(bova_11_asset[:target_total_value]).to eq(3000.0)
          expect(bova_11_asset[:target_quantity]).to eq(30.0)
          expect(bova_11_asset[:quantity_adjustment]).to eq(20.0)
        end
      end
  
      context 'when withdrawing some money' do
        let(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, investment_portfolio:, amount: -3000) }
  
        it 'calculates the before state and investment_portfolio_projected_total_value' do
          before_state = current_investment_portfolio_state
  
          expect(before_state[:investment_portfolio_projected_total_value]).to eq(0.0)
          expect(before_state[:current_investment_portfolio_state].count).to eq(2)
  
          ivvb_11_asset = before_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'IVVB11' }
          expect(ivvb_11_asset[:ticker_symbol]).to eq('IVVB11')
          expect(ivvb_11_asset[:quantity]).to eq(BigDecimal(10))
          expect(ivvb_11_asset[:target_allocation_weight_percentage]).to eq(BigDecimal(50))
          expect(ivvb_11_asset[:target_variation_limit_percentage]).to be_nil
          expect(ivvb_11_asset[:average_price]).to be_nil
          expect(ivvb_11_asset[:price]).to eq(200.0)
          expect(ivvb_11_asset[:currency]).to eq(brl_currency)
          expect(ivvb_11_asset[:original_price]).to eq(40.0)
          expect(ivvb_11_asset[:original_currency]).to eq(usd_currency)
          expect(ivvb_11_asset[:asset_price]).to be_an_instance_of(AssetPrice)
          expect(ivvb_11_asset[:currency_parity_exchange_rate]).to be_an_instance_of(CurrencyParityExchangeRate)
          expect(ivvb_11_asset[:current_total_value]).to eq(2000.0)
          expect(ivvb_11_asset[:current_allocation_weight_percentage]).to eq(0)
          expect(ivvb_11_asset[:current_variation_percentage]).to eq(-50.0)
          expect(ivvb_11_asset[:target_total_value]).to eq(0)
          expect(ivvb_11_asset[:target_quantity]).to eq(0)
          expect(ivvb_11_asset[:quantity_adjustment]).to eq(-10.0)
  
          bova_11_asset = before_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'BOVA11' }
          expect(bova_11_asset[:ticker_symbol]).to eq('BOVA11')
          expect(bova_11_asset[:quantity]).to eq(BigDecimal(10))
          expect(bova_11_asset[:target_allocation_weight_percentage]).to eq(BigDecimal(50))
          expect(bova_11_asset[:target_variation_limit_percentage]).to be_nil
          expect(bova_11_asset[:average_price]).to be_nil
          expect(bova_11_asset[:price]).to eq(100.0)
          expect(bova_11_asset[:currency]).to eq(brl_currency)
          expect(bova_11_asset[:original_price]).to eq(100.0)
          expect(bova_11_asset[:original_currency]).to eq(brl_currency)
          expect(bova_11_asset[:asset_price]).to be_an_instance_of(AssetPrice)
          expect(bova_11_asset[:currency_parity_exchange_rate]).to be_nil
          expect(bova_11_asset[:current_total_value]).to eq(1000.0)
          expect(bova_11_asset[:current_allocation_weight_percentage]).to eq(0.0)
          expect(bova_11_asset[:current_variation_percentage]).to eq(-50.0)
          expect(bova_11_asset[:target_total_value]).to eq(0.0)
          expect(bova_11_asset[:target_quantity]).to eq(0.0)
          expect(bova_11_asset[:quantity_adjustment]).to eq(-10.0)
        end
      end
    end

    # TODO
    context 'when rebalance_order kind is average_price' do
      context 'when not depositing or withdrawing money' do
        
      end

      context 'when depositing some money' do
        
      end

      context 'when withdrawing some money' do
        
      end
    end
  end
end
