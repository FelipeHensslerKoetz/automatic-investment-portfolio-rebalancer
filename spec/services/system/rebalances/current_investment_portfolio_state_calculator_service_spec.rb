require 'rails_helper'

RSpec.describe System::Rebalances::CurrentInvestmentPortfolioStateCalculatorService do
  describe '.call' do
    subject(:current_investment_portfolio_state) { described_class.call(investment_portfolio:, amount:, rebalance_kind: ) }

    let(:user) { create(:user) }
    let!(:brl_currency) { create(:currency, :brl) }
    let(:usd_currency) { create(:currency, :usd) }
    let(:amount) { rebalance_order.amount }
    let(:investment_portfolio) { create(:investment_portfolio, user:) }
    let(:ivvb_11) { create(:asset, ticker_symbol: 'IVVB11') }
    let(:bova_11) { create(:asset, ticker_symbol: 'BOVA11') }
    let(:btc_11) { create(:asset, ticker_symbol: 'BTC11') }
    let(:rebalance_kind) { rebalance_order.kind }

    context 'when rebalance_order kind is default' do
      before do
        create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: ivvb_11, currency: usd_currency, status: :updated, price: 40.0)
        create(:investment_portfolio_asset, investment_portfolio:, asset: ivvb_11, target_allocation_weight_percentage: 50, quantity: 10)
        create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: bova_11, currency: brl_currency, status: :updated,
                                                                      price: 100.0)
        create(:investment_portfolio_asset, investment_portfolio:, asset: bova_11, target_allocation_weight_percentage: 50,
                                            quantity: 10)
  
        brl_usd_currency_parity = create(:currency_parity, currency_from: usd_currency, currency_to: brl_currency)
        create(:currency_parity_exchange_rate, :with_hg_brasil_currencies_partner_resource, currency_parity: brl_usd_currency_parity,
                                                                                            exchange_rate: 5.0,
                                                                                            status: :updated)
      end
  
      context 'when not depositing or withdrawing money' do
        let(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, investment_portfolio:) }
  
        it 'calculates the current investment portfolio state and investment_portfolio_projected_total_value' do
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
          expect(ivvb_11_asset[:current_variation_percentage]).to eq(BigDecimal('0.333333333333333333333333333333333334e2'))
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
          expect(bova_11_asset[:current_variation_percentage]).to eq(BigDecimal('-0.333333333333333333333333333333333334e2'))
          expect(bova_11_asset[:target_total_value]).to eq(1500.0)
          expect(bova_11_asset[:target_quantity]).to eq(15.0)
          expect(bova_11_asset[:quantity_adjustment]).to eq(5.0)
        end
      end
  
      context 'when depositing some money' do
        let(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, investment_portfolio:, amount: 3000) }
  
        it 'calculates the current investment portfolio state and investment_portfolio_projected_total_value' do
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
          expect(ivvb_11_asset[:current_allocation_weight_percentage]).to eq(BigDecimal('0.666666666666666666666666666666666667e2'))
          expect(ivvb_11_asset[:current_variation_percentage]).to eq(BigDecimal('0.333333333333333333333333333333333334e2'))
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
          expect(bova_11_asset[:current_allocation_weight_percentage]).to eq(BigDecimal('0.333333333333333333333333333333333333e2'))
          expect(bova_11_asset[:current_variation_percentage]).to eq(BigDecimal('-0.333333333333333333333333333333333334e2'))
          expect(bova_11_asset[:target_total_value]).to eq(3000.0)
          expect(bova_11_asset[:target_quantity]).to eq(30.0)
          expect(bova_11_asset[:quantity_adjustment]).to eq(20.0)
        end
      end
  
      context 'when withdrawing some money' do
        let(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, investment_portfolio:, amount: -3000) }
  
        it 'calculates the current investment portfolio state and investment_portfolio_projected_total_value' do
          current_state = current_investment_portfolio_state
  
          expect(current_state[:investment_portfolio_projected_total_value]).to eq(0.0)
          expect(current_state[:current_investment_portfolio_state].count).to eq(2)
  
          ivvb_11_asset = current_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'IVVB11' }
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
          expect(ivvb_11_asset[:current_variation_percentage]).to eq(BigDecimal('0.333333333333333333333333333333333334e2'))
          expect(ivvb_11_asset[:target_total_value]).to eq(0)
          expect(ivvb_11_asset[:target_quantity]).to eq(0)
          expect(ivvb_11_asset[:quantity_adjustment]).to eq(-10.0)
  
          bova_11_asset = current_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'BOVA11' }
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
          expect(bova_11_asset[:current_variation_percentage]).to eq(BigDecimal('-0.333333333333333333333333333333333334e2'))
          expect(bova_11_asset[:target_total_value]).to eq(0.0)
          expect(bova_11_asset[:target_quantity]).to eq(0.0)
          expect(bova_11_asset[:quantity_adjustment]).to eq(-10.0)
        end
      end
    end

    context 'when rebalance_order kind is contribution' do
      let(:rebalance_order) { create(:rebalance_order, :contribution, status: :scheduled, investment_portfolio:, amount:) }

      let(:stock_a) { create(:asset, ticker_symbol: 'STOCK_A') }
      let(:stock_b) { create(:asset, ticker_symbol: 'STOCK_B') }
      let(:stock_c) { create(:asset, ticker_symbol: 'STOCK_C') }

      before do 
        create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: stock_a, currency: brl_currency, status: :updated,
        price: 1.0)
        create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: stock_b, currency: brl_currency, status: :updated,
        price: 1.0)
        create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: stock_c, currency: brl_currency, status: :updated,
        price: 1.0)
      end

      
      context 'when the investment_portfolios is not perfectly balanced' do
        context 'when the amount difference to total_deficit is negative' do
          let(:amount) { 1000 }

          before do 
            create(:investment_portfolio_asset, investment_portfolio:, asset: stock_a, target_allocation_weight_percentage: 40, quantity: 4000)
            create(:investment_portfolio_asset, investment_portfolio:, asset: stock_b, target_allocation_weight_percentage: 35, quantity: 2000)
            create(:investment_portfolio_asset, investment_portfolio:, asset: stock_c, target_allocation_weight_percentage: 25, quantity: 2000)
          end

          it 'distributes the contribution amount proportionally between the assets' do
            current_state = current_investment_portfolio_state

            expect(current_state[:investment_portfolio_projected_total_value]).to eq(BigDecimal(9000))
            expect(current_state[:current_investment_portfolio_state].count).to eq(3)

            stock_a_asset = current_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'STOCK_A' }
            expect(stock_a_asset[:ticker_symbol]).to eq('STOCK_A')
            expect(stock_a_asset[:quantity]).to eq(BigDecimal(4000))
            expect(stock_a_asset[:target_allocation_weight_percentage]).to eq(BigDecimal(40))
            expect(stock_a_asset[:target_variation_limit_percentage]).to be_nil
            expect(stock_a_asset[:price]).to eq(1.0)
            expect(stock_a_asset[:currency]).to eq(brl_currency)
            expect(stock_a_asset[:original_price]).to eq(1.0)
            expect(stock_a_asset[:original_currency]).to eq(brl_currency)
            expect(stock_a_asset[:asset_price]).to be_an_instance_of(AssetPrice)
            expect(stock_a_asset[:currency_parity_exchange_rate]).to be_nil
            expect(stock_a_asset[:current_total_value]).to eq(4000.0)
            expect(stock_a_asset[:current_allocation_weight_percentage]).to eq(BigDecimal(50))
            expect(stock_a_asset[:current_variation_percentage]).to eq(25)
            expect(stock_a_asset[:target_total_value]).to eq(4000.0)
            expect(stock_a_asset[:target_quantity]).to eq(4000.0)
            expect(stock_a_asset[:quantity_adjustment]).to eq(0)

            stock_b_asset = current_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'STOCK_B' }
            expect(stock_b_asset[:ticker_symbol]).to eq('STOCK_B')
            expect(stock_b_asset[:quantity]).to eq(BigDecimal(2000))
            expect(stock_b_asset[:target_allocation_weight_percentage]).to eq(BigDecimal(35))
            expect(stock_b_asset[:target_variation_limit_percentage]).to be_nil
            expect(stock_b_asset[:price]).to eq(1.0)
            expect(stock_b_asset[:currency]).to eq(brl_currency)
            expect(stock_b_asset[:original_price]).to eq(1.0)
            expect(stock_b_asset[:original_currency]).to eq(brl_currency)
            expect(stock_b_asset[:asset_price]).to be_an_instance_of(AssetPrice)
            expect(stock_b_asset[:currency_parity_exchange_rate]).to be_nil
            expect(stock_b_asset[:current_total_value]).to eq(2000.0)
            expect(stock_b_asset[:current_allocation_weight_percentage]).to eq(BigDecimal(25))
            expect(stock_b_asset[:current_variation_percentage]).to eq(BigDecimal('-0.28571428571428571428571428571428571429e2'))
            expect(stock_b_asset[:target_total_value]).to eq(BigDecimal('0.2821428571428571428571428571428571429e4'))
            expect(stock_b_asset[:target_quantity]).to eq(BigDecimal('0.2821428571428571428571428571428571429e4'))
            expect(stock_b_asset[:quantity_adjustment]).to eq(BigDecimal('0.821428571428571428571428571428571429e3'))
            
            stock_c_asset = current_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'STOCK_C' }
            expect(stock_c_asset[:ticker_symbol]).to eq('STOCK_C')
            expect(stock_c_asset[:quantity]).to eq(BigDecimal(2000))
            expect(stock_c_asset[:target_allocation_weight_percentage]).to eq(BigDecimal(25))
            expect(stock_c_asset[:target_variation_limit_percentage]).to be_nil
            expect(stock_c_asset[:price]).to eq(1.0)
            expect(stock_c_asset[:currency]).to eq(brl_currency)
            expect(stock_c_asset[:original_price]).to eq(1.0)
            expect(stock_c_asset[:original_currency]).to eq(brl_currency)
            expect(stock_c_asset[:asset_price]).to be_an_instance_of(AssetPrice)
            expect(stock_c_asset[:currency_parity_exchange_rate]).to be_nil
            expect(stock_c_asset[:current_total_value]).to eq(2000.0)
            expect(stock_c_asset[:current_allocation_weight_percentage]).to eq(BigDecimal(25))
            expect(stock_c_asset[:current_variation_percentage]).to eq(0)
            expect(stock_c_asset[:target_total_value]).to eq(BigDecimal('0.2178571428571428571428571428571428571e4'))
            expect(stock_c_asset[:target_quantity]).to eq(BigDecimal('0.2178571428571428571428571428571428571e4'))
            expect(stock_c_asset[:quantity_adjustment]).to eq(BigDecimal('0.178571428571428571428571428571428571e3'))

            expect(current_state[:current_investment_portfolio_state].sum { |asset_details| asset_details[:target_quantity] *  asset_details[:price] }).to eq(BigDecimal(9000))
            expect(current_state[:current_investment_portfolio_state].sum { |asset_details| asset_details[:quantity] * asset_details[:price]}).to eq(BigDecimal(8000))
          end
        end

        context 'when the amount difference to total_deficit is zero' do
          let(:amount) { 1000 }
  
          before do 
            create(:investment_portfolio_asset, investment_portfolio:, asset: stock_a, target_allocation_weight_percentage: 40, quantity: 4000)
            create(:investment_portfolio_asset, investment_portfolio:, asset: stock_b, target_allocation_weight_percentage: 35, quantity: 3500)
            create(:investment_portfolio_asset, investment_portfolio:, asset: stock_c, target_allocation_weight_percentage: 25, quantity: 2500)
          end
  
          it 'distributes the contribution amount equally between the assets' do
            current_state = current_investment_portfolio_state
  
            expect(current_state[:investment_portfolio_projected_total_value]).to eq(BigDecimal(11000))
            expect(current_state[:current_investment_portfolio_state].count).to eq(3)
  
            stock_a_asset = current_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'STOCK_A' }
            expect(stock_a_asset[:ticker_symbol]).to eq('STOCK_A')
            expect(stock_a_asset[:quantity]).to eq(BigDecimal(4000))
            expect(stock_a_asset[:target_allocation_weight_percentage]).to eq(BigDecimal(40))
            expect(stock_a_asset[:target_variation_limit_percentage]).to be_nil
            expect(stock_a_asset[:price]).to eq(1.0)
            expect(stock_a_asset[:currency]).to eq(brl_currency)
            expect(stock_a_asset[:original_price]).to eq(1.0)
            expect(stock_a_asset[:original_currency]).to eq(brl_currency)
            expect(stock_a_asset[:asset_price]).to be_an_instance_of(AssetPrice)
            expect(stock_a_asset[:currency_parity_exchange_rate]).to be_nil
            expect(stock_a_asset[:current_total_value]).to eq(4000.0)
            expect(stock_a_asset[:current_allocation_weight_percentage]).to eq(BigDecimal(40))
            expect(stock_a_asset[:current_variation_percentage]).to eq(0)
            expect(stock_a_asset[:target_total_value]).to eq(4400.0)
            expect(stock_a_asset[:target_quantity]).to eq(4400.0)
            expect(stock_a_asset[:quantity_adjustment]).to eq(400)
  
            stock_b_asset = current_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'STOCK_B' }
            expect(stock_b_asset[:ticker_symbol]).to eq('STOCK_B')
            expect(stock_b_asset[:quantity]).to eq(BigDecimal(3500))
            expect(stock_b_asset[:target_allocation_weight_percentage]).to eq(BigDecimal(35))
            expect(stock_b_asset[:target_variation_limit_percentage]).to be_nil
            expect(stock_b_asset[:price]).to eq(1.0)
            expect(stock_b_asset[:currency]).to eq(brl_currency)
            expect(stock_b_asset[:original_price]).to eq(1.0)
            expect(stock_b_asset[:original_currency]).to eq(brl_currency)
            expect(stock_b_asset[:asset_price]).to be_an_instance_of(AssetPrice)
            expect(stock_b_asset[:currency_parity_exchange_rate]).to be_nil
            expect(stock_b_asset[:current_total_value]).to eq(3500.0)
            expect(stock_b_asset[:current_allocation_weight_percentage]).to eq(BigDecimal(35))
            expect(stock_b_asset[:current_variation_percentage]).to eq(0)
            expect(stock_b_asset[:target_total_value]).to eq(3850.0)
            expect(stock_b_asset[:target_quantity]).to eq(3850.0)
            expect(stock_b_asset[:quantity_adjustment]).to eq(350)
  
            stock_c_asset = current_state[:current_investment_portfolio_state].find { |asset_details| asset_details[:ticker_symbol] == 'STOCK_C' }
            expect(stock_c_asset[:ticker_symbol]).to eq('STOCK_C')
            expect(stock_c_asset[:quantity]).to eq(BigDecimal(2500))
            expect(stock_c_asset[:target_allocation_weight_percentage]).to eq(BigDecimal(25))
            expect(stock_c_asset[:target_variation_limit_percentage]).to be_nil
            expect(stock_c_asset[:price]).to eq(1.0)
            expect(stock_c_asset[:currency]).to eq(brl_currency)
            expect(stock_c_asset[:original_price]).to eq(1.0)
            expect(stock_c_asset[:original_currency]).to eq(brl_currency)
            expect(stock_c_asset[:asset_price]).to be_an_instance_of(AssetPrice)
            expect(stock_c_asset[:currency_parity_exchange_rate]).to be_nil
            expect(stock_c_asset[:current_total_value]).to eq(2500.0)
            expect(stock_c_asset[:current_allocation_weight_percentage]).to eq(BigDecimal(25))
            expect(stock_c_asset[:current_variation_percentage]).to eq(0)
            expect(stock_c_asset[:target_total_value]).to eq(2750.0)
            expect(stock_c_asset[:target_quantity]).to eq(2750.0)
            expect(stock_c_asset[:quantity_adjustment]).to eq(250)
  
            expect(current_state[:current_investment_portfolio_state].sum { |asset_details| asset_details[:target_quantity] *  asset_details[:price] }).to eq(BigDecimal(11000))
            expect(current_state[:current_investment_portfolio_state].sum { |asset_details| asset_details[:quantity] * asset_details[:price]}).to eq(BigDecimal(10000))
          end
        end
      end
    end
  end
end
