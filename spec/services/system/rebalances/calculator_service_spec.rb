# frozen_string_literal: true

require 'rails_helper'

RSpec.describe System::Rebalances::CalculatorService do
  subject(:rebalance_service) { described_class.call(rebalance_order_id:) }

  let(:user) { create(:user) }
  let!(:brl_currency) { create(:currency, :brl) }

  describe '.call' do
    context 'when rebalance requirements are met' do
      let(:usd_currency) { create(:currency, :usd) }
      let(:rebalance_order_id) { rebalance_order.id }
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
          let(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, kind: 'default', investment_portfolio:) }

          it 'calculates the rebalance and generate a Rebalance record' do
            rebalance_service

            rebalance = rebalance_order.rebalance

            expect(rebalance_order.reload.status).to eq('succeed')
            expect(rebalance).to be_a(Rebalance)
            expect(rebalance.current_investment_portfolio_state.count).to eq(2)
            expect(rebalance.current_investment_portfolio_state.sum { |asset_details| asset_details['target_total_value'].to_d }).to eq(
              rebalance.details['investment_portfolio_projected_total_value'].to_d
            )
            expect(rebalance.projected_investment_portfolio_state_with_rebalance_actions.count).to eq(2)
            expect(rebalance.projected_investment_portfolio_state_with_rebalance_actions.sum { |asset_details| asset_details['target_total_value'].to_d }).to eq(
              rebalance.details['investment_portfolio_projected_total_value'].to_d
            )
            expect(rebalance.details).to include(
              'rebalance_order_kind' => 'default',
              'investment_portfolio_id' => investment_portfolio.id,
              'rebalance_order_amount' => '0.0',
              'investment_portfolio_projected_total_value' => '3000.0'
            )
            expect(rebalance.recommended_actions).to eq({
                                                          'buy' => [{ 'quantity' => '5.0', 'ticker_symbol' => 'BOVA11' }],
                                                          'sell' => [{ 'quantity' => '2.5', 'ticker_symbol' => 'IVVB11' }]
                                                        })

            expect(InvestmentPortfolioRebalanceNotificationOrder.count).to be_zero
          end
        end

        context 'when depositing money' do
          let(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, investment_portfolio:, amount: 3000) }

          it 'calculates the rebalance and generate a Rebalance record' do
            rebalance_service

            rebalance = rebalance_order.rebalance

            expect(rebalance_order.reload.status).to eq('succeed')
            expect(rebalance).to be_a(Rebalance)
            expect(rebalance.current_investment_portfolio_state.count).to eq(2)
            expect(rebalance.current_investment_portfolio_state.sum { |asset_details| asset_details['target_total_value'].to_d }).to eq(
              rebalance.details['investment_portfolio_projected_total_value'].to_d
            )
            expect(rebalance.projected_investment_portfolio_state_with_rebalance_actions.count).to eq(2)
            expect(rebalance.projected_investment_portfolio_state_with_rebalance_actions.sum { |asset_details| asset_details['target_total_value'].to_d }).to eq(
              rebalance.details['investment_portfolio_projected_total_value'].to_d
            )
            expect(rebalance.details).to include(
              'rebalance_order_kind' => 'default',
              'investment_portfolio_id' => investment_portfolio.id,
              'rebalance_order_amount' => '3000.0',
              'investment_portfolio_projected_total_value' => '6000.0'
            )
            expect(rebalance.recommended_actions).to eq({
                                                          'buy' => [{ 'quantity' => '5.0', 'ticker_symbol' => 'IVVB11' },
                                                                    { 'quantity' => '20.0', 'ticker_symbol' => 'BOVA11' }],
                                                          'sell' => []
                                                        })

            expect(InvestmentPortfolioRebalanceNotificationOrder.count).to be_zero
          end
        end

        context 'when withdrawing money' do
          let(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, investment_portfolio:, amount: -3000) }

          it 'calculates the rebalance and generate a Rebalance record' do
            rebalance_service

            rebalance = rebalance_order.rebalance

            expect(rebalance_order.reload.status).to eq('succeed')
            expect(rebalance).to be_a(Rebalance)
            expect(rebalance.current_investment_portfolio_state.count).to eq(2)
            expect(rebalance.current_investment_portfolio_state.sum { |asset_details| asset_details['target_total_value'].to_d }).to eq(
              rebalance.details['investment_portfolio_projected_total_value'].to_d
            )
            expect(rebalance.projected_investment_portfolio_state_with_rebalance_actions.count).to eq(2)
            expect(rebalance.projected_investment_portfolio_state_with_rebalance_actions.sum { |asset_details| asset_details['target_total_value'].to_d }).to eq(
              rebalance.details['investment_portfolio_projected_total_value'].to_d
            )
            expect(rebalance.details).to include(
              'rebalance_order_kind' => 'default',
              'investment_portfolio_id' => investment_portfolio.id,
              'rebalance_order_amount' => '-3000.0',
              'investment_portfolio_projected_total_value' => '0.0'
            )
            expect(rebalance.recommended_actions).to eq({
                                                          'buy' => [],
                                                          'sell' => [{ 'quantity' => '10.0', 'ticker_symbol' => 'IVVB11' },
                                                                     { 'quantity' => '10.0', 'ticker_symbol' => 'BOVA11' }]
                                                        })

            expect(InvestmentPortfolioRebalanceNotificationOrder.count).to be_zero
          end
        end
      end

      # TODO
      context 'when rebalance_order kind is average_price' do
        context 'when not depositing or withdrawing money' do
        end

        context 'when depositing money' do
        end

        context 'when withdrawing money' do
        end
      end

      context 'when the investment portfolio has a notification options' do
        let(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, kind: 'default', investment_portfolio:) }

        before do
          create(:investment_portfolio_rebalance_notification_option, :email, investment_portfolio:)
          create(:investment_portfolio_rebalance_notification_option, :webhook, investment_portfolio:)
        end

        it 'calculates the rebalance and generate a Rebalance record and create the notification orders' do
          rebalance_service

          rebalance = rebalance_order.rebalance

          expect(rebalance_order.reload.status).to eq('succeed')
          expect(rebalance).to be_a(Rebalance)
          expect(rebalance.current_investment_portfolio_state.count).to eq(2)
          expect(rebalance.current_investment_portfolio_state.sum { |asset_details| asset_details['target_total_value'].to_d }).to eq(
            rebalance.details['investment_portfolio_projected_total_value'].to_d
          )
          expect(rebalance.projected_investment_portfolio_state_with_rebalance_actions.count).to eq(2)
          expect(rebalance.projected_investment_portfolio_state_with_rebalance_actions.sum { |asset_details| asset_details['target_total_value'].to_d }).to eq(
            rebalance.details['investment_portfolio_projected_total_value'].to_d
          )
          expect(rebalance.details).to include(
            'rebalance_order_kind' => 'default',
            'investment_portfolio_id' => investment_portfolio.id,
            'rebalance_order_amount' => '0.0',
            'investment_portfolio_projected_total_value' => '3000.0'
          )
          expect(rebalance.recommended_actions).to eq({
                                                        'buy' => [{ 'quantity' => '5.0', 'ticker_symbol' => 'BOVA11' }],
                                                        'sell' => [{ 'quantity' => '2.5', 'ticker_symbol' => 'IVVB11' }]
                                                      })

          expect(InvestmentPortfolioRebalanceNotificationOrder.count).to eq(2)
          expect(investment_portfolio.investment_portfolio_rebalance_notification_orders.count).to eq(2)
        end
      end
    end

    context 'when rebalance requirements are not met' do
      context 'when the rebalance order is not found' do
        let(:rebalance_order_id) { -1 }

        it 'creates an error log' do
          rebalance_service

          error_log = Log.last

          expect(error_log.kind).to eq('error')
          expect(error_log.data['context']).to eq('System::Rebalances::CalculatorService - rebalance_order_id=-1')
          expect(error_log.data['message']).to eq("ActiveRecord::RecordNotFound: Couldn't find RebalanceOrder with 'id'=-1")
          expect(Log.count).to eq(1)
        end
      end

      context 'when the rebalance order status is different from scheduled' do
        let(:rebalance_order) { create(:rebalance_order, :default, status: :processing) }
        let(:rebalance_order_id) { rebalance_order.id }
        let(:expected_error_message) do
          "RebalanceOrders::InvalidStatusError: Expecting pending status for RebalanceOrder with id #{rebalance_order_id}, " \
            'got processing status.'
        end

        it 'creates an error log' do
          rebalance_service

          error_log = Log.last

          expect(error_log.kind).to eq('error')
          expect(error_log.data['context']).to eq("System::Rebalances::CalculatorService - rebalance_order_id=#{rebalance_order_id}")
          expect(error_log.data['message']).to eq(expected_error_message)
          expect(rebalance_order.reload.status).to eq('failed')
          expect(rebalance_order.reload.error_message).to eq(expected_error_message)
          expect(Log.count).to eq(1)
        end
      end

      context 'when the investment portfolio total allocation weight is invalid' do
        let(:rebalance_order_id) { rebalance_order.id }
        let(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, investment_portfolio:) }
        let(:investment_portfolio) { create(:investment_portfolio) }
        let(:expected_error_message) do
          "InvestmentPortfolios::InvalidTotalAllocationWeightError: Investment Portfolio id: #{investment_portfolio.id} has an invalid " \
            'total allocation weight: 99.99'
        end

        before do
          asset = create(:asset)
          create(:asset_price, :with_hg_brasil_assets_partner_resource, asset:, currency: brl_currency, status: :updated)
          create(:investment_portfolio_asset, investment_portfolio:, asset:, target_allocation_weight_percentage: 50)

          second_asset = create(:asset)
          create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: second_asset, currency: brl_currency, status: :updated)
          create(:investment_portfolio_asset, investment_portfolio:, asset: second_asset, target_allocation_weight_percentage: 49.99)
        end

        it 'creates an error log' do
          rebalance_service

          error_log = Log.last

          expect(error_log.kind).to eq('error')
          expect(error_log.data['context']).to eq("System::Rebalances::CalculatorService - rebalance_order_id=#{rebalance_order_id}")
          expect(error_log.data['message']).to eq(expected_error_message)
          expect(rebalance_order.reload.error_message).to eq(expected_error_message)
          expect(rebalance_order.reload.status).to eq('failed')
          expect(Log.count).to eq(1)
        end
      end

      context 'when the investment portfolio assets count is invalid' do
        let(:rebalance_order_id) { rebalance_order.id }
        let!(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, investment_portfolio:) }
        let!(:investment_portfolio) { create(:investment_portfolio) }
        let(:expected_error_message) do
          "InvestmentPortfolios::InvalidAssetsCountError: Investment Portfolio #{investment_portfolio.id} has an invalid number of assets: 0"
        end

        it 'creates an error log' do
          rebalance_service

          error_log = Log.last

          expect(error_log.kind).to eq('error')
          expect(error_log.data['context']).to eq("System::Rebalances::CalculatorService - rebalance_order_id=#{rebalance_order_id}")
          expect(error_log.data['message']).to eq(expected_error_message)
          expect(rebalance_order.reload.error_message).to eq(expected_error_message)
          expect(rebalance_order.reload.status).to eq('failed')
          expect(Log.count).to eq(1)
        end
      end

      context 'when any of the the investment portfolio assets prices are not up to date' do
        let(:rebalance_order_id) { rebalance_order.id }
        let!(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, investment_portfolio:) }
        let!(:investment_portfolio) { create(:investment_portfolio) }
        let!(:investment_portfolio_asset) do
          create(:investment_portfolio_asset, investment_portfolio:, target_allocation_weight_percentage: 50)
        end
        let!(:investment_portfolio_asset2) do
          create(:investment_portfolio_asset, investment_portfolio:, target_allocation_weight_percentage: 50)
        end
        let(:expected_error_message) { "Assets::OutdatedError: Asset with id: #{investment_portfolio_asset.asset.id} is outdated." }

        it 'creates an error log' do
          rebalance_service

          error_log = Log.last

          expect(error_log.kind).to eq('error')
          expect(error_log.data['context']).to eq("System::Rebalances::CalculatorService - rebalance_order_id=#{rebalance_order_id}")
          expect(error_log.data['message']).to eq(expected_error_message)
          expect(rebalance_order.reload.error_message).to eq(expected_error_message)
          expect(rebalance_order.reload.status).to eq('failed')
          expect(Log.count).to eq(1)
        end
      end

      context 'when withdrawal value is greater than current investment_portfolio value' do
        let(:usd_currency) { create(:currency, :usd) }
        let(:rebalance_order_id) { rebalance_order.id }
        let(:investment_portfolio) { create(:investment_portfolio, user:) }
        let(:rebalance_order) { create(:rebalance_order, :default, status: :scheduled, investment_portfolio:, amount: -30_000) }
        let(:expected_error_message) do
          'RebalanceOrders::InvalidWithdrawAmountError: Insufficient funds to withdraw 30000.0, the max withdraw is 3000.0.'
        end

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

        it 'creates an error log' do
          rebalance_service

          error_log = Log.last

          expect(error_log.kind).to eq('error')
          expect(error_log.data['context']).to eq("System::Rebalances::CalculatorService - rebalance_order_id=#{rebalance_order_id}")
          expect(error_log.data['message']).to eq(expected_error_message)
          expect(rebalance_order.reload.error_message).to eq(expected_error_message)
          expect(rebalance_order.reload.status).to eq('failed')
          expect(Log.count).to eq(1)
        end
      end

      # TODO
      context 'when the kind is average_price and the investment portfolio has assets without a average_price set' do
      end

      # TODO
      context 'when the investment portfolio has a deviation automatic rebalance option but the investment portfolio has assets without de variation set' do
      end
    end
  end
end
